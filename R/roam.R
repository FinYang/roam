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
#' \code{new_roam} creates a roam object using the user defined \code{obtainer} function.
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
#' @param obtainer a user defined function to download data/object.
#' The first argument should be the version number user wants to download.
#' If input \code{NULL}, the obtainer function should download the latest version.
#' @param ... optional arguments to \code{obtainer}.
#' @return \code{new_roam} returns a function with class \code{roam_object}.
#' @name roam
#' @export
new_roam <- function(package, name, obtainer, ...) {
  force(obtainer)
  x <- NULL
  nonexist_msg <- sprintf(
    'The roam data object "%s" in package %s does not exist locally', name, package)
  structure(
    function(...) {
      # Skip on tests, never test.
      # testing if installed package can be loaded from final location
      # triggers evaluation of active bindings
      if(!is.na(Sys.getenv("R_TESTS", unset = NA))) return(invisible(NULL))

      roam_flag$package <- package
      on.exit(roam_flag$package <- NULL, add = TRUE)
      roam_flag$name <- name
      on.exit(roam_flag$name <- NULL, add = TRUE)

      # check object exists in cache
      file <- paste0(name, ".RData")
      path <- cache_path(package, file)
      if(roam_flag$delete) {
        unlink(path)
        cat(sprintf('Cache of data "%s" in package "%s" is deleted',
                    name, package))
        return(invisible(NULL))
      }
      if(!file.exists(path) || roam_flag$install) {
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
        if(!roam_flag$install && isFALSE(getOption("roam.autodownload", default = FALSE))){
          if(!interactive()) {
            stop(paste(nonexist_msg, "You can automatically download missing roam objects by setting the `options(roam.autodownload = TRUE)`", sep = "\n"))
          } else {
            cat(nonexist_msg)
            if(!utils::askYesNo("Would you like to download and cache it?")) return(invisible(NULL))
          }
        }
        # obtain object with obtainer()
        dir_create(dirname(path))
        x <<- obtainer(roam_flag$version, ...)
        cat("Data retrieved")
        save(x, file = path)
      } else if(is.null(x)){
        # load() and return object from cache
        load(path)
        x <<- x
      }
      x
    },
    class = "roam_object",
    package = package, name = name
  )
}
dir_create <- function(x){
  dir.exists(x) || dir.create(x, recursive = TRUE)
}

roam_flag <- new.env(parent = emptyenv())
roam_flag$install <- FALSE
roam_flag$delete <- FALSE
roam_flag$version <- NULL
roam_flag$package <- NULL
roam_flag$name <- NULL


#' @describeIn roam Update the local cache of the roam active binding
#' using the user defined obtainer function
#' @return \code{roam_update} returns the updated local cache of the roam active binding
#' @export
roam_update <- function(x){
  roam_install(x, version = NULL)
}

#' @describeIn roam Install (Download) the local cache of the roam active binding
#' of a specific version
#' using the user defined obtainer function
#' @param x roam active binding
#' @param version In [roam_install()] version of the data to install. If \code{NULL}, the latest version.
#' In [roam_version()], the version of the currently downloading data.
#' @return \code{roam_install} returns the installed local cache of the roam active binding
#' @export
roam_install <- function(x, version = NULL) {
  roam_flag$install <- TRUE
  roam_flag$version <- version
  on.exit(roam_flag$install <- FALSE, add = TRUE)
  on.exit(roam_flag$version <- NULL, add = TRUE)
  x
}

#' @describeIn roam Save the currently downloading version number when used in the obtainer function,
#' where \code{package} and \code{name} should not be specified.
#' To obtain the current version of a roam object in a package when used outside the
#' obtain function, where \code{version} should not be specified.
#' @return \code{roam_version} returns the version.
#' @export
roam_version <- function(version = NULL, package = NULL, name = NULL) {
  if(!is.null(version)) {
    if(is.null(roam_flag$package))
      stop("If `version` is specified, `roam_version()` can only be used inside an obtainer function.")
    if(!is.null(package) || !is.null(name))
      stop("When `roam_version()` is used inside an obtainer function, please do not specify the `paciage` and `name` arguments.
           Please report to the maintainer of package ", roam_flag$package)
    name <- roam_flag$name
    package <- roam_flag$package

    file <- paste0(name, ".txt")
    path <- cache_path(package, file)
    writeLines(version, path)
  } else {
    if(is.null(package) || is.null(name))
      stop("When `version` is not specifed, both `package` and `name` should be specified.")
    file <- paste0(name, ".txt")
    path <- cache_path(package, file)
    if(!file.exists(path)) {
      cat("Not installed.")
    } else {
      version <- readLines(path)
    }
  }

  version
}


#' @describeIn roam Delete the local cache of the roam active binding
#' @export
roam_delete <- function(x){
  roam_flag$delete <- TRUE
  on.exit(roam_flag$delete <- FALSE)
  x
}

#' @describeIn roam Activate a roam object to an active binding.
#' Used in the [.onLoad] function of a package
#' @return All the other functions return invisible \code{NULL}.
#' @export
roam_activate <- function(x) {
  if(!inherits(x, "roam_object")) stop("Input is not a roam_object. Did you try to activate the same object twice?")
  env <- environment(environment(x)$obtainer)
  name <- attr(x, "name")
  # unlockBinding(name, env)
  if(exists(name, envir = env)) remove(list = name, envir = env)
  makeActiveBinding(name, x, env)
}

#' @describeIn roam Activate all the roam objects in the given package.
#' Used in the [.onLoad] function of a package
#' @export
roam_activate_all <- function(package){
  pkg_namespace <- as.list(asNamespace(package))
  roam_which <- vapply(pkg_namespace, inherits, what = "roam_object", logical(1L))
  lapply(pkg_namespace[roam_which], roam_activate)
  return(invisible(NULL))
}
