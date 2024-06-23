
<!-- README.md is generated from README.Rmd. Please edit that file -->

# roam <img src="man/figures/logo.svg" align="right" height="139" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/roam)](https://CRAN.R-project.org/package=roam)
[![R-CMD-check](https://github.com/finyang/roam/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/finyang/roam/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of roam is to …

1.  Allow ‘regular looking’ R objects in packages to exceed the 5MB
    limit.
2.  Support updating of datasets without updating packages by using
    functions that pull from remote resources.
3.  Make it easy for packages to include these ‘roaming’ datasets.

## Installation

You can install the **stable** version from
[CRAN](https://cran.r-project.org/package=roam).

``` r
install.packages("roam")
```

You can install the **development** version from
[Github](https://github.com/FinYang/roam)

``` r
# install.packages("remotes")
remotes::install_github("FinYang/roam")
```

## Example

``` r
library(roam)
bee <- new_roam(
  "roam", "bee", 
  function(version) 
    read.csv(
      "https://raw.githubusercontent.com/finyang/roam/master/demo/bee_colonies.csv"))


roam_activate(bee)

head(bee)
#> The roam data object "bee" in package roam does not exist locally
#> Would you like to download and cache it? (Yes/no/cancel) 
```

*The data is downloaded to a local cache using {rappdirs}, then returned
as the data itself*

    #> Data retrieved
    #>   X year        months       state colony_n colony_max colony_lost
    #> 1 1 2015 January-March     Alabama     7000       7000        1800
    #> 2 2 2015 January-March     Arizona    35000      35000        4600
    #> 3 3 2015 January-March    Arkansas    13000      14000        1500
    #> 4 4 2015 January-March  California  1440000    1690000      255000
    #> 5 5 2015 January-March    Colorado     3500      12500        1500
    #> 6 6 2015 January-March Connecticut     3900       3900         870
    #>   colony_lost_pct colony_added colony_reno colony_reno_pct
    #> 1              26         2800         250               4
    #> 2              13         3400        2100               6
    #> 3              11         1200          90               1
    #> 4              15       250000      124000               7
    #> 5              12          200         140               1
    #> 6              22          290          NA              NA

### Accessing cached data

``` r
head(bee)
#>   X year        months       state colony_n colony_max colony_lost
#> 1 1 2015 January-March     Alabama     7000       7000        1800
#> 2 2 2015 January-March     Arizona    35000      35000        4600
#> 3 3 2015 January-March    Arkansas    13000      14000        1500
#> 4 4 2015 January-March  California  1440000    1690000      255000
#> 5 5 2015 January-March    Colorado     3500      12500        1500
#> 6 6 2015 January-March Connecticut     3900       3900         870
#>   colony_lost_pct colony_added colony_reno colony_reno_pct
#> 1              26         2800         250               4
#> 2              13         3400        2100               6
#> 3              11         1200          90               1
#> 4              15       250000      124000               7
#> 5              12          200         140               1
#> 6              22          290          NA              NA
```

### Updating cached data

``` r
head(roam_update(bee))
#> Data retrieved
#>   X year        months       state colony_n colony_max colony_lost
#> 1 1 2015 January-March     Alabama     7000       7000        1800
#> 2 2 2015 January-March     Arizona    35000      35000        4600
#> 3 3 2015 January-March    Arkansas    13000      14000        1500
#> 4 4 2015 January-March  California  1440000    1690000      255000
#> 5 5 2015 January-March    Colorado     3500      12500        1500
#> 6 6 2015 January-March Connecticut     3900       3900         870
#>   colony_lost_pct colony_added colony_reno colony_reno_pct
#> 1              26         2800         250               4
#> 2              13         3400        2100               6
#> 3              11         1200          90               1
#> 4              15       250000      124000               7
#> 5              12          200         140               1
#> 6              22          290          NA              NA
```

### Deleting cached data

``` r
roam_delete(bee)
#> Cache of data "bee" in package "roam" is deleted
```
