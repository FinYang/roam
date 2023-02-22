new_roam <- function(package, name, obtainer, ...) {
  force(obtainer)
  structure(
    function(v, ..., delete = FALSE, update = FALSE) {
      if(!missing(v)) stop("Can't use `<-` yet, sorry!")
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

roam_activate <- function(x, env = parent.frame(2)) {
  name <- attr(x, "name")
  remove(list = name, envir = env)
  makeActiveBinding(name, x, env)
}
