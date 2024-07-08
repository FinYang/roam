cache_path <- function(package, name) {
  file.path(
    rappdirs::user_data_dir("r-roam"),
    package, name
  )
}

cache_path_data <- function(package, name)
  cache_path(package, paste0(name, ".RData"))
cache_path_version <- function(package, name)
  cache_path(package, paste0(name, ".txt"))

roam_cache <- function(x, version, package, name) {
  save(x, file = cache_path_data(package, name))
  writeLines(as.character(version), cache_path_version(package, name))
}

roam_unlink <- function(package, name) {
  unlink(cache_path_data(package, name))
  unlink(cache_path_version(package, name))
  cat(sprintf('Cache of data "%s" in package "%s" is deleted',
              name, package))
  return(invisible(NULL))
}
