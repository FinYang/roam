#' Create and manage roam object and their active bindings
#'
#' Helper functions for package developers to create active bindings
#' that looks like data embedded in the package, but are downloaded from remote sources.
#'
#' Users of the package using roam data object can treat the roam active bindings
#' as if they are regular data embedded in the package.
#' The first time a user calls the roam active binding, they will be prompted to
#' download the data using the \code{obtainer} function.
#' The \code{obtainer} function defines how the package developer wants to
#' download or generate data.
#' Once the data are downloaded, they will be cached locally using \code{rappdirs}.
#' The users can then use the data object as normal.
#'
#' \code{new_roam} creates a roam object using the package writer/roam object creator defined \code{obtainer} function.
#' The roam object created using \code{new_roam} is not an active binding.
#' The active bindings are not preserved during package installation,
#' so the package developer needs to activate the roam object and turn it
#' into an active binding in the [.onLoad] function
#' using either \code{roam_activate} or \code{roam_activate_all}.
#'
#' \code{roam_activate} takes one roam object and activates it.
#' \code{roam_activate_all} looks through the namespace
#' and activates all the roam objects in the package.
#'
#' If there are a lot of objects in the package,
#' calling \code{roam_activate} on each roam object in [.onLoad]
#' might save some package loading time than calling \code{roam_activate_all}
#' once.
#'
#' @param package the name of the package as a string.
#' @param name the name of the roam object.
#' Should be the same as the name to which the roam object is assigned.
#' @param obtainer a package writer/roam object creator defined function to download data/object.
#' Should include one argument named \code{version} to specify the version number user wants to download.
#' If input \code{"latest"}, the obtainer function should download the latest version.
#' @param ... optional arguments to \code{obtainer}, other than \code{version}.
#' @return \code{new_roam} returns a function with class \code{roam_object}.
#' @name roam
#' @examples
#' # Define the roam object
#' bee <- new_roam(
#'   "roam", "bee",
#'   function(version)
#'   read.csv(
#'     "https://raw.githubusercontent.com/finyang/roam/master/demo/bee_colonies.csv"
#'   ))
#' # Activation
#' roam_activate(bee)
#' if (interactive()) {
#'   # Download
#'   roam_install(bee)
#'   # or in an interative session, simply
#'   bee
#'   # Access
#'   bee
#'   # Update
#'   roam_update(bee)
#'   # Deleting cache
#'   roam_delete(bee)
#' }
#' @export
new_roam <- function(package, name, obtainer, ...) {
  force(obtainer)
  # save the caller environment of new_roam()
  # used to activate roam_object
  # and for reassigning value
  caller_env <- parent.frame()
  x <- NULL
  nonexist_msg <- sprintf(
    'The roam data object "%s" in package %s does not exist locally',
    name,
    package
  )
  dots <- list(...)
  if (any(names(dots) == "versio")) {
    stop(
      "Optional arguments to the obtainer in ... cannot have an argument named 'version'."
    )
  }
  structure(
    function(...) {
      # Skip on tests, never test.
      # testing if installed package can be loaded from final location
      # triggers evaluation of active bindings
      if (!is.na(Sys.getenv("R_TESTS", unset = NA))) {
        return(invisible(NULL))
      }

      if (!missing(...)) {
        value_to_assign <- list(...)[[1]]
        # caller_env:
        # where the active binding is defined/activated/can be called by assign.

        # delete it on exit
        on.exit(rm(list = name, pos = caller_env))
        # assign a new value to the same name on exit
        on.exit(assign(name, value_to_assign, pos = caller_env), add = TRUE)
        # This process reassigns a value to the name,
        # instead of applying the function on the value
        # as it does for active bindings
        return(value_to_assign)
      }

      # check object exists in cache
      file <- paste0(name, ".RData")
      path <- cache_path(package, file)
      if (roam_flag$delete) {
        if (
          !(file.exists(cache_path_data(package, name)) &&
            file.exists(cache_path_version(package, name)))
        ) {
          cat(nonexist_msg)
        } else {
          roam_unlink(package, name)
        }
        return(invisible(NULL))
      }
      if (!file.exists(path) || roam_flag$install) {
        # Check if it is evaluated by Rstudio autocomplete or autohelp
        # If it is, skip evaluation
        if (
          length(scalls <- sys.calls()) > 1 &&
            (identical(scalls[[1]][[1]], as.name(".rs.rpc.get_completions")) ||
              identical(scalls[[1]][[1]], as.name(".rs.rpc.get_help")))
        ) {
          return(invisible(NULL))
        }
        # if not interactive session
        # Only download using function or option
        if (
          !roam_flag$install &&
            isFALSE(getOption("roam.autodownload", default = FALSE))
        ) {
          if (!interactive()) {
            stop(paste(
              nonexist_msg,
              "You can automatically download missing roam objects by setting the `options(roam.autodownload = TRUE)`",
              sep = "\n"
            ))
          } else {
            cat(nonexist_msg)
            answer_cache <- utils::askYesNo(
              "Would you like to download and cache it?"
            )
            if (is.na(answer_cache) || !answer_cache) {
              return(invisible(NULL))
            }
          }
        }
        # obtain object with obtainer()
        dir_create(dirname(path))
        # Do not pass version "latest" to cache
        version <- roam_flag$version
        roam_flag$version <- NA_character_

        x <<- do.call(obtainer, c(dots, version = version))

        on.exit(roam_flag$version <- NA_character_, add = TRUE)
        cat("Data retrieved")
        roam_cache(x, version = roam_flag$version, package, name)
      } else if (is.null(x)) {
        # load() and return object from cache
        load(path)
        x <<- x
      }
      x
    },
    class = "roam_object",
    package = package,
    name = name
  )
}
dir_create <- function(x) {
  dir.exists(x) || dir.create(x, recursive = TRUE)
}

roam_flag <- new.env(parent = emptyenv())
roam_flag$install <- FALSE
roam_flag$delete <- FALSE
roam_flag$version <- NA_character_


#' @describeIn roam Update the local cache of the roam active binding
#' using the package writer/roam object creator defined obtainer function
#' @return \code{roam_update} returns the updated local cache of the roam active binding
#' @export
roam_update <- function(x) {
  roam_install(x)
}

#' @describeIn roam Install (Download) the local cache of the roam active binding
#' of a specific version
#' using the package writer/roam object creator defined obtainer function
#' @param x roam active binding
#' @param version In [roam_install()] version of the data to install. If \code{"latest"}, the latest version.
#' In [roam_set_version()], the version of the currently downloading data.
#' @return \code{roam_install} returns the installed local cache of the roam active binding
#' @export
roam_install <- function(x, version = "latest") {
  roam_flag$install <- TRUE
  roam_flag$version <- version
  on.exit(roam_flag$install <- FALSE, add = TRUE)
  on.exit(roam_flag$version <- NA_character_, add = TRUE)
  x
}

#' @describeIn roam
#' For package writers to use inside the obtainer function, save the currently downloading version number.
#' @return \code{roam_set_version} returns the version invisibly.
#' @export
roam_set_version <- function(version = NA_character_) {
  roam_flag$version <- version
  invisible(version)
}

#' @describeIn roam
#' Find the current version of a roam object in a package.
#' @return \code{roam_version} returns the version.
#' @export
roam_version <- function(package, name) {
  file <- paste0(name, ".txt")
  path <- cache_path(package, file)
  if (!file.exists(path)) {
    cat("Not installed.")
    version <- NA_character_
  } else {
    version <- readLines(path)
  }

  version
}


#' @describeIn roam Delete the local cache of the roam active binding
#' @export
roam_delete <- function(x) {
  roam_flag$delete <- TRUE
  on.exit(roam_flag$delete <- FALSE)
  x
}

#' @describeIn roam Activate a roam object to an active binding.
#' Used in the [.onLoad] function of a package
#' @return All the other functions return invisible \code{NULL}.
#' @export
roam_activate <- function(x) {
  if (!inherits(x, "roam_object")) {
    stop(
      "Input is not a roam_object. Did you try to activate the same object twice?"
    )
  }
  # the environment where new_roam is called
  env <- environment(x)$caller_env
  name <- attr(x, "name")
  # unlockBinding(name, env)
  if (exists(name, envir = env)) {
    remove(list = name, envir = env)
  }
  makeActiveBinding(name, x, env)
}

#' @describeIn roam Activate all the roam objects in the given package.
#' Used in the [.onLoad] function of a package
#' @export
roam_activate_all <- function(package) {
  pkg_namespace <- as.list(asNamespace(package))
  roam_which <- vapply(
    pkg_namespace,
    inherits,
    what = "roam_object",
    logical(1L)
  )
  lapply(pkg_namespace[roam_which], roam_activate)
  return(invisible(NULL))
}
