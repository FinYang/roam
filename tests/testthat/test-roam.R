# should have locally installed roam
test_package <- function(quiet = FALSE) {
  if (!requireNamespace("roam")) {
    return(list(
      errors = character(),
      warnings = character(),
      notes = character()
    ))
  }
  pkg_path <- tempfile(pattern = "roamtest")
  on.exit(unlink(pkg_path, recursive = TRUE))
  usethis::create_package(pkg_path, roxygen = FALSE, open = FALSE)
  # usethis::create_package(pkg_path, roxygen = FALSE)

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
  roam_activate_all("%s")
})",
      basename(pkg_path),
      basename(pkg_path)
    ),
    con = file.path(pkg_path, "R", "roamtest.R")
  )

  cat(
    "Depends: roam\n",
    file = file.path(pkg_path, "DESCRIPTION"),
    append = TRUE
  )

  check_output <- devtools::check(pkg_path, quiet = quiet, error_on = "never")
  check_output
}


test_that("R CMD check of package that uses roam", {
  skip_on_cran()
  check_output <- test_package(quiet = TRUE)
  expect_length(check_output$errors, 0)
  expect_length(check_output$warnings, 0)
  expect_length(check_output$notes, 0)
})
