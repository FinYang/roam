# should have locally installed roam
# this actually can run github
# Looks like roam is installed in the environment first,
# then the tests run.
test_package <- function(quiet = FALSE, open = FALSE) {
  if (!requireNamespace("roam")) {
    return(list(
      errors = character(),
      warnings = character(),
      notes = character()
    ))
  }
  pkg_path <- tempfile(pattern = "roamtest")
  if (!open) {
    on.exit(unlink(pkg_path, recursive = TRUE))
  }
  usethis::create_package(pkg_path, roxygen = FALSE, open = open)
  # usethis::create_package(pkg_path, roxygen = FALSE)

  dir.create(file.path(pkg_path, "man"))
  writeLines(
    r"(\docType{data}
\name{bee}
\alias{bee}
\title{beeeeeeee}
\format{
buzzzzzzzz
}
\usage{
bee
}
\description{
beeeeeeee
}
\keyword{datasets}
)",
    con = file.path(pkg_path, "man", "roamtest.Rd")
  )

  writeLines(
    sprintf(
      r"(
bee <- new_roam(
  "%s",
  "bee",
  function(version) {
    "bee"
  }
)
.onLoad <- function(libname, pkgname) {
  roam::roam_activate_all("%s")
})",
      basename(pkg_path),
      basename(pkg_path)
    ),
    con = file.path(pkg_path, "R", "roamtest.R")
  )

  cat(
    r"(import(roam))",
    file = file.path(pkg_path, "NAMESPACE"),
    append = TRUE
  )
  cat(
    sprintf(
      r"(Package: %s
Title: What the Package Does (One Line, Title Case)
Version: 0.0.0.9000
Authors@R: 
    person("First", "Last", , "first.last@example.com", role = c("aut", "cre"))
Description: What the package does (one paragraph).
License: CC0
Encoding: UTF-8
Depends: 
  roam
)",
      basename(pkg_path)
    ),
    file = file.path(pkg_path, "DESCRIPTION")
  )

  # cat(
  #   "Depends: roam\n",
  #   file = file.path(pkg_path, "DESCRIPTION"),
  #   append = TRUE
  # )
  all_files <- dir(
    pkg_path,
    all.files = TRUE,
    full.names = TRUE,
    recursive = TRUE,
    include.dirs = TRUE
  )
  print(getwd())
  print(all_files)
  for (rd in all_files[!basename(all_files) %in% c("R", "man")]) {
    cat("FILE:  ", rd, "\n")
    lines <- try(readLines(rd, warn = FALSE))
    if (!"try-error" %in% class(lines)) {
      cat(paste(lines, collapse = "\n"))
    }
    cat("\n")
  }

  check_output <- devtools::check(pkg_path, quiet = quiet, error_on = "never")
  check_output
}


test_that("R CMD check of package that uses roam", {
  skip_on_cran()
  check_output <- test_package(quiet = FALSE)
  print(check_output)
  expect_length(check_output$errors, 0)
  expect_length(check_output$warnings, 0)
  expect_length(check_output$notes, 0)
})
