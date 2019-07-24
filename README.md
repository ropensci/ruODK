
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ruODK: ODK Central API wrapper <img src="man/figures/ruODK.png" align="right" alt="Are you ODK?" width="120" />

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![GitHub
issues](https://img.shields.io/github/issues/dbca-wa/ruodk.svg?style=popout)](https://github.com/dbca-wa/ruODK/issues)
[![Travis build
status](https://travis-ci.org/dbca-wa/ruODK.svg?branch=master)](https://travis-ci.org/dbca-wa/ruODK)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/dbca-wa/ruODK?branch=master&svg=true)](https://ci.appveyor.com/project/dbca-wa/ruODK)
[![Coverage
status](https://codecov.io/gh/dbca-wa/ruODK/branch/master/graph/badge.svg)](https://codecov.io/github/dbca-wa/ruODK?branch=master)
<!-- badges: end -->

Especially in these trying times, it is important to ask: “r u ODK?”

[ODK Central](https://docs.opendatakit.org/central-intro/) an Open Data
Kit server alternative to ODK Aggregate. It manages user accounts and
permissions, stores form definitions, and allows data collection clients
like ODK Collect to connect to it for form download and submission
upload.

After data have been captured digitally using ODK Collect, the data are
uploaded and stored in ODK Central. The next step from there is to
extract the data, optionally upload it into another data warehouse, and
then to analyse and generate insight from it.

While data can be retrieved in bulk through the GUI, ODK Central’s API
provides access to its data and functionality through both an OData and
a RESTful API with a comprehensive and interactive
[documentation](https://odkcentral.docs.apiary.io/#reference/odata-endpoints).

ruODK aims:

  - To wrap all ODK Central API endpoints with a focus on data access.
  - To provide working examples of interacting with the ODK Central API.
  - To provide convenience helpers for the day to day tasks when working
    with ODK Central data in R.

Out of scope:

  - Wrap “management” API endpoints. The ODK Central GUI is a fantastic
    interface for the management of users, roles, permissions, projects,
    and forms.
  - Extensive data visualisation. We show only minimal examples of data
    visualisation and presentation, mainly to illustrate the example
    data.

## Install

You can install ruODK from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("dbca-wa/ruODK")
```

## ODK Central

First, we need some data to play with\!

The ODK Central [user
manual](https://docs.opendatakit.org/central-using/) provides up-to-date
descriptions of the steps below.

  - [Create a web user
    account](https://docs.opendatakit.org/central-users/#creating-a-web-user)
    on an ODK Central instance. Your username will be an email address.
  - [Create a project](https://docs.opendatakit.org/central-projects/)
    and give the web user the relevant permissions.
  - Create a Xform, e.g. using ODK Build, or use the provided example
    forms.
  - [Publish the form](https://docs.opendatakit.org/central-forms/) to
    ODK Central.
  - Collect some data for this form on ODK Collect and let ODK Collect
    submit the finalised forms to ODK Central.

A note on the [included example
forms](https://github.com/dbca-wa/ruODK/tree/master/inst/extdata): The
`.odkbuild` versions can be loaded into [ODK
Build](https://build.opendatakit.org/), while the `.xml` versions can be
imported into ODK Central.

## Configure ruODK

Read [`vignette("Setup", package =
"ruODK")`](https://dbca-wa.github.io/ruODK/articles/setup.html) for
detailed options to configure `ruODK`.

For a quick start, run the following chunk with your settings:

``` r
Sys.setenv(ODKC_URL = "https://odkcentral.mydomain.com")
Sys.setenv(ODKC_UN = "me@mail.com")
Sys.setenv(ODKC_PW = ".......")
```

## Use ruODK

A quick example:

``` r
library(ruODK)

# ODK Central credentials
if (file.exists("~/.Rprofile")) source("~/.Rprofile")
# .RProfile sets ODKC_{URL, UN, PW}

# ODK Central OData service URL
# "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-2_1558575936.svc"

# Download from ODK Central
proj <- project_list()
proj
#> # A tibble: 4 x 8
#>      id name  archived forms appUsers lastSubmission     
#>   <int> <chr> <chr>    <int>    <int> <dttm>             
#> 1     1 DBCA  <NA>         6        1 2019-07-23 03:06:52
#> 2     3 Flora <NA>         1        1 NA                 
#> 3     2 Spot… <NA>         3        1 2019-06-26 07:12:25
#> 4     4 DBCA  TRUE         0        0 NA                 
#> # … with 2 more variables: createdAt <dttm>, updatedAt <dttm>

meta <- ruODK::get_metadata(
  pid = 1,
  fid = "build_Turtle-Sighting-0-1_1559790020"
)
# listviewer::jsonedit(meta)

data <- ruODK::get_submissions(
  pid = 1,
  fid = "build_Turtle-Sighting-0-1_1559790020"
) %>%
  ruODK::parse_submissions()
data %>% head(.)
#> # A tibble: 6 x 20
#>   .__id submissionDate submitterId submitterName instanceID
#>   <chr> <chr>          <chr>       <chr>         <chr>     
#> 1 uuid… 2019-07-22T01… 16          Turtles       uuid:ddee…
#> 2 uuid… 2019-07-22T01… 16          Turtles       uuid:0b25…
#> 3 uuid… 2019-07-22T01… 16          Turtles       uuid:05ca…
#> 4 uuid… 2019-07-22T01… 16          Turtles       uuid:1351…
#> 5 uuid… 2019-07-22T01… 16          Turtles       uuid:f175…
#> 6 uuid… 2019-07-22T01… 16          Turtles       uuid:8141…
#> # … with 15 more variables: observation_start_time <chr>, reporter <chr>,
#> #   device_id <chr>, type <chr>, ...10 <dbl>, ...11 <dbl>, ...12 <dbl>,
#> #   species <chr>, sex <chr>, maturity <chr>, activity <chr>,
#> #   observer_acticity <chr>, photo_habitat <chr>,
#> #   observation_end_time <chr>, .odata.context <chr>
```

A more detailed walk-through with some data visualisation examples is
available in the [`vignette("odata",
package="ruODK")`](https://dbca-wa.github.io/ruODK/articles/odata.html).

See also [`vignette("restapi",
package="ruODK")`](https://dbca-wa.github.io/ruODK/articles/api.html)
for examples of the alternative RESTful API.

## Contribute

Contributions through [issues](https://github.com/dbca-wa/ruODK/issues)
and PRs are welcome\!

## Release

These steps prepare a new `ruODK` release.

``` r
styler::style_pkg()
goodpractice::goodpractice(quiet = FALSE)
devtools::test()
codemetar::write_codemeta("ruODK")
devtools::document(roclets = c("rd", "collate", "namespace"))
spelling::spell_check_package()
devtools::check()
pkgdown::build_site()
```

## Acknowledgements

The Department of Biodiversity, Conservation and Attractions (DBCA)
respectfully acknowledges Aboriginal people as the traditional owners of
the lands and waters it manages.

One of the Department’s core missions is to conserve and protect the
value of the land to the culture and heritage of Aboriginal people.

This software was created both as a contribution to the ODK ecosystem
and for the conservation of the biodiversity of Western Australia, and
in doing so, caring for country.
