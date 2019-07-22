
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ruODK: ODK Central API wrapper <img src="man/figures/ruODK.png" align="right" alt="Are you ODK?" width="120" />

<!-- badges: start -->

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
Kit server alternative like ODK Aggregate. It manages user accounts and
permissions, stores form definitions, and allows data collection clients
like ODK Collect to connect to it for form download and submission
upload.

ODK Central’s API provides access to its data and functionality through
both an OData and a RESTful API. It is accompanied by a comprehensive
and interactive
[documentation](https://odkcentral.docs.apiary.io/#reference/odata-endpoints).

ruODK aims:

  - To wrap all ODK Central API endpoints. This is a work in progress
    with focus on “getting the data out” first.
  - To provide working examples of interacting with the ODK Central API.
  - To provide convenience helpers for the day to day tasks when working
    with ODK Central data in R.

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
  - [Get the ODK Central OData service
    URL](https://docs.opendatakit.org/central-submissions/#connecting-to-submission-data-over-odata)
    for the form.

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

ruODK aims to provide the same access to your submissions via ODK
Central’s OData service endpoints as MS Excel, MS PowerBI and Tableau.

At the end of this step, we want to achieve the same outcome as the
[manual download to
CSV](https://docs.opendatakit.org/central-submissions/#downloading-submissions-as-csvs).

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
meta <- ruODK::get_metadata(
  pid = 1,
  fid = "build_Turtle-Sighting-0-1_1559790020"
)
data <- ruODK::get_submissions(
  pid = 1,
  fid = "build_Turtle-Sighting-0-1_1559790020"
) %>%
  ruODK::parse_submissions()
```

A more detailed walk-through with some data visualisation examples is
available in the [`vignette("odata",
package="ruODK")`](https://dbca-wa.github.io/ruODK/articles/odata.html).

## Contribute

Contributions through [issues](https://github.com/dbca-wa/ruODK/issues)
and PRs are welcome\!

## Release

These steps prepare a new `ruODK` release.

``` r
styler::style_pkg()
goodpractice::goodpractice(quiet = FALSE)
devtools::test()
devtools::document(roclets = c("rd", "collate", "namespace"))
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
