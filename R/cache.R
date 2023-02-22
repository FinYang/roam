cache_path <- function(package, name) {
  file.path(
    rappdirs::user_data_dir("r-roam"),
    package, name
  )
}

