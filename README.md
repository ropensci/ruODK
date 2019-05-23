
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ruODK

Especially in these trying times, it is important to ask: “R U ODK?”

This package aims to provide support, and with that we mean technical
support, to the data wranglers trying to get data out of ODK’s new data
warehouse, ODK Central.

Note: this package is in early stages and not feature complete.
Contributions and feedback are welcome\!

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
odk_central <- "https://sandbox.central.opendatakit.org/"
project_id <- 14
form_id <- "build_Flora-Quadrat-0-2_1558575936"

base_url <- glue::glue("{odk_central}v1/projects/{project_id}/forms/")
data_url <- glue::glue("{base_url}{form_id}.svc")

# Download from ODK Central
metadata <- get_metadata(data_url)
data_raw <- get_submissions(data_url)
```

See the vignette “Example” for a walk-through plus data tidying and
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
