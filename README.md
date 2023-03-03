
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
bee <- new_roam(
  "roam", "bee",
  function() {
    read.csv(
      "https://raw.githubusercontent.com/mitchelloharawild/roam/main/demo/bee_colonies.csv"
    )
  }
)

roam_activate(bee)

head(bee)
#> The roam data object "bee" in package roam does not exist locally
#> Would you like to download and cache it? (Yes/no/cancel)
```

*The data is downloaded to a local cache using {rappdirs}, then returned
as the data itself*

    #> Data retrieved
    #>   X year        months       state colony_n colony_max colony_lost colony_lost_pct colony_added colony_reno colony_reno_pct
    #> 1 1 2015 January-March     Alabama     7000       7000        1800              26         2800         250               4
    #> 2 2 2015 January-March     Arizona    35000      35000        4600              13         3400        2100               6
    #> 3 3 2015 January-March    Arkansas    13000      14000        1500              11         1200          90               1
    #> 4 4 2015 January-March  California  1440000    1690000      255000              15       250000      124000               7
    #> 5 5 2015 January-March    Colorado     3500      12500        1500              12          200         140               1
    #> 6 6 2015 January-March Connecticut     3900       3900         870              22          290          NA              NA

### Accessing cached data

``` r
head(bee)
#>   X year        months       state colony_n colony_max colony_lost colony_lost_pct colony_added colony_reno colony_reno_pct
#> 1 1 2015 January-March     Alabama     7000       7000        1800              26         2800         250               4
#> 2 2 2015 January-March     Arizona    35000      35000        4600              13         3400        2100               6
#> 3 3 2015 January-March    Arkansas    13000      14000        1500              11         1200          90               1
#> 4 4 2015 January-March  California  1440000    1690000      255000              15       250000      124000               7
#> 5 5 2015 January-March    Colorado     3500      12500        1500              12          200         140               1
#> 6 6 2015 January-March Connecticut     3900       3900         870              22          290          NA              NA
```

### Updating cached data

``` r
head(roam_update(bee))
#> Data retrieved
#>   X year        months       state colony_n colony_max colony_lost colony_lost_pct colony_added colony_reno colony_reno_pct
#> 1 1 2015 January-March     Alabama     7000       7000        1800              26         2800         250               4
#> 2 2 2015 January-March     Arizona    35000      35000        4600              13         3400        2100               6
#> 3 3 2015 January-March    Arkansas    13000      14000        1500              11         1200          90               1
#> 4 4 2015 January-March  California  1440000    1690000      255000              15       250000      124000               7
#> 5 5 2015 January-March    Colorado     3500      12500        1500              12          200         140               1
#> 6 6 2015 January-March Connecticut     3900       3900         870              22          290          NA              NA
```

### Deleting cached data

``` r
roam_delete(bee)
#> Cache of data "bee" in package "roam" is deleted
```

You can even use other package’s data.

``` r
library(fitzRoy)

aflm_season_2020 <- new_roam(
  "fitZroy", "aflm_season_2020",
  function() {
    fetch_fixture(season = 2020, comp = "AFLM")
  }
)

roam_activate(aflm_season_2020)

aflm_season_2020
#> # A tibble: 162 × 55
#>       id providerId utcSt…¹ status compS…² compS…³ compS…⁴ compS…⁵ compS…⁶ round…⁷ round…⁸ round…⁹ round…˟ round…˟ round…˟ home.…˟ home.…˟ home.…˟ home.…˟ home.…˟ home.…˟ home.…˟ home.…˟
#>    <int> <chr>      <chr>   <chr>    <int> <chr>   <chr>   <chr>     <int>   <int> <chr>   <chr>   <chr>     <int> <list>    <int> <chr>   <chr>   <chr>   <chr>   <chr>     <int> <chr>  
#>  1  2214 CD_M20200… 2020-0… CONCL…      20 CD_S20… 2020 T… Premie…      22     263 CD_R20… Rd 1    Round 1       1 <df>         16 CD_T120 Richmo… RICH    Tigers  MEN          22 CD_O25 
#>  2  2009 CD_M20200… 2020-0… CONCL…      20 CD_S20… 2020 T… Premie…      22     263 CD_R20… Rd 1    Round 1       1 <df>          8 CD_T140 Wester… WB      Bulldo… MEN          25 CD_O31 
#>  3  2010 CD_M20200… 2020-0… CONCL…      20 CD_S20… 2020 T… Premie…      22     263 CD_R20… Rd 1    Round 1       1 <df>         12 CD_T50  Essend… ESS     Bombers MEN          10 CD_O9  
#>  4  2024 CD_M20200… 2020-0… CONCL…      20 CD_S20… 2020 T… Premie…      22     263 CD_R20… Rd 1    Round 1       1 <df>          1 CD_T10  Adelai… ADEL    Crows   MEN           3 CD_O1  
#>  5  2041 CD_M20200… 2020-0… CONCL…      20 CD_S20… 2020 T… Premie…      22     263 CD_R20… Rd 1    Round 1       1 <df>         15 CD_T10… GWS Gi… GWS     Giants  MEN           5 CD_O16 
#>  6  2027 CD_M20200… 2020-0… CONCL…      20 CD_S20… 2020 T… Premie…      22     263 CD_R20… Rd 1    Round 1       1 <df>          4 CD_T10… Gold C… GCFC    Suns    MEN           9 CD_O14 
#>  7  2028 CD_M20200… 2020-0… CONCL…      20 CD_S20… 2020 T… Premie…      22     263 CD_R20… Rd 1    Round 1       1 <df>          6 CD_T100 North … NMFC    Kangar… MEN          20 CD_O20 
#>  8  2021 CD_M20200… 2020-0… CONCL…      20 CD_S20… 2020 T… Premie…      22     263 CD_R20… Rd 1    Round 1       1 <df>          9 CD_T80  Hawtho… HAW     Hawks   MEN          16 CD_O17 
#>  9  2043 CD_M20200… 2020-0… CONCL…      20 CD_S20… 2020 T… Premie…      22     263 CD_R20… Rd 1    Round 1       1 <df>         18 CD_T150 West C… WCE     Eagles  MEN          23 CD_O30 
#> 10  2026 CD_M20200… 2020-0… CONCL…      20 CD_S20… 2020 T… Premie…      22     264 CD_R20… Rd 2    Round 2       2 <df>          3 CD_T40  Collin… COLL    Magpies MEN          12 CD_O6  
#> # … with 152 more rows, 32 more variables: home.team.club.name <chr>, home.team.club.abbreviation <chr>, home.team.club.nickname <chr>, home.score.goals <int>, home.score.behinds <int>,
#> #   home.score.totalScore <int>, home.score.superGoals <int>, away.team.id <int>, away.team.providerId <chr>, away.team.name <chr>, away.team.abbreviation <chr>,
#> #   away.team.nickname <chr>, away.team.teamType <chr>, away.team.club.id <int>, away.team.club.providerId <chr>, away.team.club.name <chr>, away.team.club.abbreviation <chr>,
#> #   away.team.club.nickname <chr>, away.score.goals <int>, away.score.behinds <int>, away.score.totalScore <int>, away.score.superGoals <int>, venue.id <int>, venue.providerId <chr>,
#> #   venue.name <chr>, venue.abbreviation <chr>, venue.location <chr>, venue.state <chr>, venue.timezone <chr>, venue.landOwner <chr>, metadata.ticket_link <chr>, compSeason.year <dbl>,
#> #   and abbreviated variable names ¹​utcStartTime, ²​compSeason.id, ³​compSeason.providerId, ⁴​compSeason.name, ⁵​compSeason.shortName, ⁶​compSeason.currentRoundNumber, ⁷​round.id,
#> #   ⁸​round.providerId, ⁹​round.abbreviation, ˟​round.name, ˟​round.roundNumber, ˟​round.byes, ˟​home.team.id, ˟​home.team.providerId, ˟​home.team.name, ˟​home.team.abbreviation, …
```
