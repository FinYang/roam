#' @export
new_roam <- function(package, name, obtainer, ...) {
  force(obtainer)
  nonexist_msg <- sprintf(
    'The roam data object "%s" in package %s does not exist locally', name, package)
  structure(
    function(...) {

      # Skip on tests, never test.
      # testing if installed package can be loaded from final location
      # triggers evaluation of active bindings
      if(!is.na(Sys.getenv("R_TESTS", unset = NA))) return(invisible(NULL))

      # Check if it is evaluated by Rstudio autocomplete
      # If it is, skip evaluation
      if (
        length(scalls <- sys.calls()) > 1 &&
        identical(scalls[[1]][[1]], as.name(".rs.rpc.get_completions"))
      ) {
        return(invisible(NULL))

      # check object exists in cache
      file <- paste0(name, ".RData")
      path <- cache_path(package, file)
      if(roam_flag$delete) {
        unlink(path)
        message(sprintf('Cache of data "%s" in package "%s" is deleted',
                        name, package))
        return(invisible(NULL))
      }
      if(!file.exists(path) || roam_flag$update) {
        # if not interactive session
        # Only download using function or option
        if(!roam_flag$update){
          if(!interactive()) {
            stop(nonexist_msg)
          } else {
            message(nonexist_msg)
            message("Would you like to download and cache it?")
            if(readline() != "Yes") return(invisible(NULL))
          }
        }
        # obtain object with obtainer()
        x <- obtainer(...)
        dir_create(dirname(path))
        save(x, file = path)
      } else {
        # load() and return object from cache
        load(path)
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
roam_flag$delete <- FALSE
makeActiveBinding(
  "update",
  local({
    update <- FALSE
    function(u = NULL){
      if(!is.null(u))
        update <<- u
      update || getOption("roam_autoupdate", default = FALSE)
    }
  }),
  env = roam_flag)

#' @export
roam_update <- function(x){
  roam_flag$update <- TRUE
  on.exit(roam_flag$update <- FALSE)
  x
}

#' @export
roam_delete <- function(x){
  roam_flag$delete <- TRUE
  on.exit(roam_flag$delete <- FALSE)
  x
}


#' @export
roam_activate <- function(x, env = environment(environment(x)$obtainer)) {
  env <- as.environment(env)
  name <- attr(x, "name")
  # unlockBinding(name, env)
  if(exists(name, envir = env)) remove(list = name, envir = env)
  makeActiveBinding(name, x, env)
}
