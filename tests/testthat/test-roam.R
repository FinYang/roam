# should have locally installed roam
# this actually can run github
# Looks like roam is installed in the environment first,
# then the tests run.
test_package <- function(quiet = FALSE, open = FALSE) {
  if (!requireNamespace("roam")) {
    stop("roam is not installed")
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

  renamed_dummy <- character()
  dummy_pkg <- setdiff(
    tools:::.get_standard_package_names()[["recommended"]],
    "codetools"
  )
  path_dummy <- file.path(.libPaths()[[1]], dummy_pkg, "dummy_for_check")
  for (dummy in path_dummy) {
    if (file.exists(dummy)) {
      if (file.rename(dummy, paste0(dummy, "_disabled"))) {
        renamed_dummy <- c(renamed_dummy, dummy)
      }
    }
  }

  check_output <- devtools::check(pkg_path, quiet = quiet, error_on = "never")

  for (dummy in renamed_dummy) {
    file.rename(paste0(dummy, "_disabled"), dummy)
  }
  github_action <- identical(Sys.getenv("GITHUB_ACTIONS"), "true")
  if (github_action) {
    if (
      any(
        vapply(
          check_output[c("errors", "warnings", "notes")],
          length,
          FUN.VALUE = integer(1L)
        ) !=
          0
      )
    ) {
      file.copy(
        pkg_path,
        "/home/runner/work/roam/roam/check/",
        recursive = TRUE
      )
    }
  }

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
