
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ruODK

[ruODK on GitHub](https://github.com/dbca-wa/ruODK) [![Travis build
status](https://travis-ci.org/dbca-wa/ruODK.svg?branch=master)](https://travis-ci.org/dbca-wa/ruODK)
[![Coverage
status](https://codecov.io/gh/dbca-wa/ruODK/branch/master/graph/badge.svg)](https://codecov.io/github/dbca-wa/ruODK?branch=master)

Especially in these trying times, it is important to ask: “R U ODK?”

This package aims to provide support, and with that we mean technical
support, to the data wranglers trying to get data out of ODK’s new data
warehouse, ODK Central.

For reference, ODK Central OData API has a fantastic comprehensive,
interactive
[documentation](https://odkcentral.docs.apiary.io/#reference/odata-endpoints).

## Installation

You can install ruODK from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("dbca-wa/ruODK")
```

## Use

### Setup ODK Central

The ODK Central [user
manual](https://docs.opendatakit.org/central-using/) provides up-to-date
descriptions of the steps below.

  - [Create a web user
    account](https://docs.opendatakit.org/central-users/#creating-a-web-user)
    on an ODK Central instance. Your username will be an email address.
  - Create a [project](https://docs.opendatakit.org/central-projects/)
    and give the web user the relevant permissions.
  - Create a Xform, e.g. using ODK Build, or use the provided example
    forms.
  - Publish the [form to ODK
    Central](https://docs.opendatakit.org/central-forms/).
  - Collect data for this form on ODK Collect.
  - Get the ODK Central OData service URL.

A note on the [included example
forms](https://github.com/dbca-wa/ruODK/tree/master/inst/extdata): The
`.odkbuild` versions can be loaded into [ODK
Build](https://build.opendatakit.org/), while the `.xml` versions can be
imported into ODK Central.

### Configure ruODK

  - Set your ODK Central username (email) and password as R environment
    variables, e.g. in your `~/.Rprofile`. Example:

<!-- end list -->

``` r
Sys.setenv(ODKC_UN="...@...")
Sys.setenv(ODKC_PW=".......")
```

### Use ruODK

ruODK aims to provide the same access to your submissions via ODK
Central’s OData service endpoints as MS Excel, MS PowerBI and Tableau.

At the end of this step, we want to achieve the same outcome as the
[manual download to
CSV](https://docs.opendatakit.org/central-submissions/#downloading-submissions-as-csvs).

Caveat: this is a work in progress. Some data doesn’t come through the
OData feed (such as location and altitude accuracy).

An [example](https://rpubs.com/florian_mayer/flora_quadrats):

``` r
# ODK Central credentials
if (file.exists("~/.Rprofile")) source("~/.Rprofile")

# ODK Central
data_url <- "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-2_1558575936.svc"

# Download from ODK Central
metadata <- get_metadata(data_url)
data <- data_url %>% get_submissions() %>% parse_submissions()
```

See `vignette("example")` for a walk-through with some data
visualisation.

## Contribute

Contributions through issues and PRs are welcome\!

## Acknowledgements

The Department of Biodiversity, Conservation and Attractions (DBCA)
respectfully acknowledges Aboriginal people as the traditional owners of
the lands and waters it manages.

One of the Department’s core missions is to conserve and protect the
value of the land to the culture and heritage of Aboriginal people.

This software was created both as a contribution to the ODK ecosystem
and for the conservation of the biodiversity of Western Australia, and
in doing so, caring for country.
