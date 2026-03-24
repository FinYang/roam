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
    on.exit(unlink(pkg_path, recursive = TRUE), add = TRUE)
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

  options(verbose = TRUE)
  print(.Library)
  print(.libPaths())
  print(dir(
    file.path(.Library, "MASS"),
    all.files = TRUE,
    full.names = TRUE,
    recursive = TRUE,
    include.dirs = TRUE
  ))
  #
  print("find MASSSSSSSSSSSSSSSSSSSSSSSSSS")
  print(try(find.package("MASS")))
  # find.package doesn't find it here!

  # what about all the packages
  base <- unlist(
    tools:::.get_standard_package_names()[c("base", "recommended")],
    use.names = FALSE
  )
  base <- base[dir.exists(file.path(.Library, base))]
  print(lapply(base, \(x) try(find.package(x))))
  pkg <- "MASS"
  lib.loc <- .libPaths()
  paths <- file.path(lib.loc, pkg)

  print(paths)
  paths <- paths[file.exists(file.path(paths, "DESCRIPTION"))]
  print(paths)
  print(file.exists(file.path(paths[1], "dummy_for_check")))
  ## dummy_for_check!!!
  # https://github.com/microsoft/microsoft-r-open/blob/a5af9887ca6b829bcbf15bf401430d1621373c25/source/src/library/tools/R/check.R#L81-L108
  # https://github.com/microsoft/microsoft-r-open/blob/a5af9887ca6b829bcbf15bf401430d1621373c25/source/src/library/tools/R/check.R#L4525-L4532
  # https://github.com/microsoft/microsoft-r-open/blob/a5af9887ca6b829bcbf15bf401430d1621373c25/source/doc/manual/R-ints.texi#L3979
  # https://stackoverflow.com/questions/57433424/r-cmd-check-warning-rd-cross-reference-no-package-available
  # https://github.com/microsoft/microsoft-r-open/blob/a5af9887ca6b829bcbf15bf401430d1621373c25/source/src/library/tools/R/check.R#L1711-L1725
  # when the check is set --as-cran, which is the default of devtools::check() and the github action
  # the check checks assuming the "recommended" packages are not available, unless declared
  # The way they do this is to create a temp library folder, link .Library to it,
  # but create empty files called dummy_for_check under each of the "recommended" package,
  # so that find.package() will pretend not to see them, even if they are in .Library,
  # which is the second item from .libPaths().
  # When checking for Rd cross-references,
  # in tools:::.check_Rd_xrefs(), tools:::Rd_aliases() is called on all the recommended package
  # which currently lives in .Library, which then triggers find.package().
  # run_tests() comes after check_pkg(), which is where check_Rd_files() is, which includes tools:::.check_Rd_xrefs().
  # The temp library is created before check_pkg(), but as far as I can tell,
  # check_pkg() doesn't use it in .libPaths(), but run_tests() does, using `elib`, an
  # output of the dummy creation, as environmental variable, which changes .libPaths().
  # This is why it is normally not a problem for normal package rd cross-reference check.
  # But for roam, there is a second check for the temp package inside the tests, which
  # uses the dummy path as the library.
  # The solution, which I wrote here in the same commit,
  # is to change the name of the dummies during this function,
  # then change them back.
  # Let see if it works.
  print(file.path(paths[1], "dummy_for_check"))
  print(isNamespaceLoaded(pkg))
  # print(.getNamespaceInfo(asNamespace(pkg), "path"))
  # paths <- c(.getNamespaceInfo(asNamespace(pkg), "path"), paths)

  db <- lapply(paths, function(p) {
    print(p)
    pfile <- file.path(p, "Meta", "package.rds")
    info <- if (file.exists(pfile)) {
      print("exists rds")
      tryCatch(
        readRDS(pfile)$DESCRIPTION[c("Package", "Version")],
        error = function(e) c(Package = NA_character_, Version = NA_character_)
      )
    } else {
      print("try dcf")
      info <- tryCatch(
        read.dcf(file.path(p, "DESCRIPTION"), c("Package", "Version"))[1, ],
        error = identity
      )
      print(info)
      if (inherits(info, "error") || (length(info) != 2L) || anyNA(info)) {
        c(Package = NA_character_, Version = NA_character_)
      } else {
        info
      }
    }
  })
  print(db)
  db <- do.call(rbind, db)
  print(db)
  valid_package_version_regexp <- .standard_regexps()$valid_package_version
  print(valid_package_version_regexp)
  ok <- (apply(!is.na(db), 1L, all) &
    (db[, "Package"] == pkg) &
    (grepl(
      valid_package_version_regexp,
      db[,
        "Version"
      ]
    )))
  print(ok)
  paths <- paths[ok]
  print(paths)

  print("GITHUB_ACTIONS")
  print(Sys.getenv("GITHUB_ACTIONS"))
  if (identical(Sys.getenv("GITHUB_ACTIONS"), "true")) {
    dummy_pkg <- setdiff(
      tools:::.get_standard_package_names()[["recommended"]],
      "codetools"
    )
    path_dummy <- file.path(.libPaths()[[1]], dummy_pkg, "dummy_for_check")
    renamed_dummy <- character()
    for (dummy in path_dummy) {
      if (file.exists(dummy)) {
        if (file.rename(dummy, paste0(dummy, "_disabled"))) {
          print(dummy)
          on.exit(file.rename(paste0(dummy, "_disabled"), dummy), add = TRUE)
        }
      }
    }
  }

  check_output <- devtools::check(pkg_path, quiet = quiet, error_on = "never")
  if (!interactive()) {
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
