
<!-- README.md is generated from README.Rmd. Please edit that file -->

# roam <img src="man/figures/logo.svg" align="right" height="139" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/roam)](https://CRAN.R-project.org/package=roam)
<!-- badges: end -->

The goal of roam is to …

1.  Allow ‘regular looking’ R objects in packages to exceed the 5MB
    limit.
2.  Support updating of datasets without updating packages by using
    functions that pull from remote resources.
3.  Make it easy for packages to include these ‘roaming’ datasets.

## Installation

You can install the development version of roam like so:

``` r
remotes::install_github("mitchelloharawild/roam")
```

## Example

``` r
library(roam)
remote_cars
#> Looks like this dataset isn't downloaded yet, would you like to download it?
#> 1. Of course!
#> 2. Never!
```

*The data is downloaded to a local cache using {rappdirs}, then returned
as the data itself*

``` r
#> # A tibble: 50 × 2
#>    speed  dist
#>    <dbl> <dbl>
#>  1     4     2
#>  2     4    10
#>  3     7     4
#>  4     7    22
#>  5     8    16
#>  6     9    10
#>  7    10    18
#>  8    10    26
#>  9    10    34
#> 10    11    17
#> # … with 40 more rows
```

<sup>Created on 2023-02-22 with [reprex
v2.0.2](https://reprex.tidyverse.org)</sup>

### Accessing cached data

``` r
remote_cars
#> # A tibble: 50 × 2
#>    speed  dist
#>    <dbl> <dbl>
#>  1     4     2
#>  2     4    10
#>  3     7     4
#>  4     7    22
#>  5     8    16
#>  6     9    10
#>  7    10    18
#>  8    10    26
#>  9    10    34
#> 10    11    17
#> # … with 40 more rows
```

### Updating cached data

``` r
remote_cars(update = TRUE)
#> Are you sure you would like to update the `remote_cars` dataset?
#>
#> 1. Sure.
#> 2. No thanks.
```

*An updated dataset is returned*

``` r
#> # A tibble: 100 × 2
#>    speed  dist
#>    <dbl> <dbl>
#>  1     4     2
#>  2     4    10
#>  3     7     4
#>  4     7    22
#>  5     8    16
#>  6     9    10
#>  7    10    18
#>  8    10    26
#>  9    10    34
#> 10    11    17
#> # … with 90 more rows
```
