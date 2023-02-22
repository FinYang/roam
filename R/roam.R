new_roam <- function(package, name, obtainer, ...) {
  force(obtainer)
  structure(
    function(..., delete = FALSE, update = FALSE) {
      # check object exists in cache
      file <- paste0(name, ".RData")
      path <- cache_path(package, file)
      if(delete) {
        unlink(path)
        message("Cache of data is deleted")
        return(invisible(NULL))
      }
      if(!file.exists(path) || update) {
        # if not, obtain object with obtainer()
        message("Downloading your data!! ;)")
        x <- obtainer(...)
        xfun::dir_create(dirname(path))
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

roam_activate <- function(x, env = environment(environment(x)$obtainer)) {
  env <- as.environment(env)
  name <- attr(x, "name")
  unlockBinding(name, env)
  if(exists(name, envir = env)) remove(list = name, envir = env)
  makeActiveBinding(name, x, env)
}
