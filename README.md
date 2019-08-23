
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ruODK: An R Client for the ODK Central API <img src="man/figures/ruODK.png" align="right" alt="Are you ODK?" width="120" />

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![GitHub
issues](https://img.shields.io/github/issues/dbca-wa/ruodk.svg?style=popout)](https://github.com/dbca-wa/ruODK/issues)
[![Travis build
status](https://travis-ci.org/dbca-wa/ruODK.svg?branch=master)](https://travis-ci.org/dbca-wa/ruODK)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/dbca-wa/ruODK?branch=master&svg=true)](https://ci.appveyor.com/project/dbca-wa/ruODK)
[![Coverage
status](https://codecov.io/gh/dbca-wa/ruODK/branch/master/graph/badge.svg)](https://codecov.io/github/dbca-wa/ruODK?branch=master)
<!-- badges: end -->

Especially in these trying times, it is important to ask: “ruODK?”

[OpenDataKit](https://opendatakit.org/) (ODK) is a free and open-source
software for collecting, managing, and using data in
resource-constrained environments.

ODK consists of a range of [software packages and
apps](https://opendatakit.org/software/). For a detailed overview, read
the extensive [ODK documentation](https://docs.opendatakit.org/).

[ODK Central](https://docs.opendatakit.org/central-intro/) is a
cloud-based data clearinghouse for digitally captured data, replacing
the older software [ODK
Aggregate](https://docs.opendatakit.org/aggregate-intro/). ODK Central
manages user accounts and permissions, stores form definitions, and
allows data collection clients like ODK Collect to connect to it for
form download and submission upload.

After data have been captured digitally using ODK Collect, the data are
uploaded and stored in ODK Central. The next step from there is to
extract the data, optionally upload it into another data warehouse, and
then to analyse and generate insight from it.

While data can be retrieved in bulk through the GUI, ODK Central’s API
provides access to its data and functionality through both an OData and
a RESTful API with a comprehensive and interactive
[documentation](https://odkcentral.docs.apiary.io/#reference/odata-endpoints).

`ruODK`’s scope:

  - To wrap all ODK Central API endpoints with a focus on **data
    access**.
  - To provide working examples of interacting with the ODK Central API.
  - To provide convenience helpers for the day to day tasks when working
    with ODK Central data in R: **data munging** the ODK Central API
    output into tidy R formats.

`ruODK`’s use cases:

  - Smaller projects:
      - Data collection: ODK Collect `%>%`
      - Data clearinghouse: ODK Central `%>%`
      - Data analysis and reporting: `Rmd` (ruODK) `%>%`
      - Publishing and dissemination:
        [`ckanr`](https://docs.ropensci.org/ckanr/),
        [`CKAN`](https://ckan.org/)
  - Larger projects:
      - Data collection: ODK Collect `%>%`
      - Data clearinghouse: ODK Central `%>%`
      - ETL pipeline into data warehouses: `Rmd` (ruODK) `%>%`
      - QA: in data warehouse `%>%`
      - Reporting: `Rmd` `%>%`
      - Publishing and dissemination:
        [`ckanr`](https://docs.ropensci.org/ckanr/),
        [`CKAN`](https://ckan.org/)

Out of scope:

  - To wrap “management” API endpoints. The ODK Central GUI provides a
    comprehensive interface for the management of users, roles,
    permissions, projects, and forms. Behind the scenes, it is a [VueJS
    application](https://github.com/opendatakit/central-frontend/)
    working on the “management” API endpoints of the ODK Central
    backend.
  - To provide extensive data visualisation. We show only minimal
    examples of data visualisation and presentation, mainly to
    illustrate the example data. Once the data is in your hands as tidy
    tibbles… u r ODK\!

## Install

You can install ruODK from GitHub with:

``` r
# install.packages("devtools")
remotes::install_github("dbca-wa/ruODK", dependencies = TRUE)
```

## ODK Central

### ODK Central instance

First, we need an ODK Central instance and some data to play with\!

Either ask in the \[ODK forum\] for an account in the [ODK Central
Sandbox](https://sandbox.central.opendatakit.org/), or follow the [setup
instructions](https://docs.opendatakit.org/central-intro/) to build and
deploy your very own ODK Central instance.

### ODK Central setup

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

For a quick start, create R environment variables with your settings:

``` r
Sys.setenv(ODKC_URL = "https://odkcentral.mydomain.com")
Sys.setenv(ODKC_UN = "me@mail.com")
Sys.setenv(ODKC_PW = ".......")
```

For a more permanent configuration setting, paste the above lines into
your `~/.Rprofile` (`usethis::edit_r_profile()`) and restart R.

For all available detailed options to configure `ruODK`, read
`vignette("Setup", package = "ruODK")` (online
[here](https://dbca-wa.github.io/ruODK/articles/setup.html)).

## Use ruODK

A quick example using the OData service:

``` r
library(ruODK)

# ODK Central credentials
if (file.exists("~/.Rprofile")) source("~/.Rprofile")
# .RProfile sets ODKC_{URL, UN, PW}

# Download from ODK Central
proj <- project_list()
proj
#> # A tibble: 4 x 8
#>      id name  forms app_users last_submission     created_at         
#>   <int> <chr> <int>     <int> <dttm>              <dttm>             
#> 1     1 DBCA      9         1 2019-08-23 00:05:19 2019-06-05 09:12:44
#> 2     3 Flora     1         1 2019-08-12 04:47:05 2019-06-06 03:24:31
#> 3     2 Spot…     3         1 2019-06-26 07:12:25 2019-06-06 03:24:15
#> 4     4 DBCA      0         0 NA                  2019-06-27 02:54:30
#> # … with 2 more variables: updated_at <dttm>, archived <lgl>

meta <- ruODK::odata_metadata_get(
  pid = 1,
  fid = "build_Turtle-Sighting-0-1_1559790020"
)
# listviewer::jsonedit(meta)
meta$Edmx$DataServices$Schema
#> $ComplexType
#> $ComplexType$Property
#> list()
#> attr(,"Name")
#> [1] "submissionDate"
#> attr(,"Type")
#> [1] "Edm.DateTimeOffset"
#> 
#> $ComplexType$Property
#> list()
#> attr(,"Name")
#> [1] "submitterId"
#> attr(,"Type")
#> [1] "Edm.String"
#> 
#> $ComplexType$Property
#> list()
#> attr(,"Name")
#> [1] "submitterName"
#> attr(,"Type")
#> [1] "Edm.String"
#> 
#> $ComplexType$Property
#> list()
#> attr(,"Name")
#> [1] "status"
#> attr(,"Type")
#> [1] "org.opendatakit.submission.Status"
#> 
#> attr(,"Name")
#> [1] "metadata"
#> 
#> $EnumType
#> $EnumType$Member
#> list()
#> attr(,"Name")
#> [1] "NotDecrypted"
#> 
#> $EnumType$Member
#> list()
#> attr(,"Name")
#> [1] "MissingEncryptedFormData"
#> 
#> attr(,"Name")
#> [1] "Status"
#> 
#> attr(,"Namespace")
#> [1] "org.opendatakit.submission"
#> attr(,"xmlns")
#> [1] "http://docs.oasis-open.org/odata/ns/edm"

data <- ruODK::odata_submission_get(
  pid = 1,
  fid = "build_Turtle-Sighting-0-1_1559790020"
) %>%
  ruODK::odata_submission_parse()
data %>% head(.)
#> # A tibble: 6 x 21
#>   .__id observation_sta… reporter device_id observation_end… submissionDate
#>   <chr> <chr>            <chr>    <chr>     <chr>            <chr>         
#> 1 uuid… 2019-08-22T16:0… Scott W… e249db9e… 2019-08-22T16:0… 2019-08-23T00…
#> 2 uuid… 2019-08-22T14:5… Scott W… e249db9e… 2019-08-22T14:5… 2019-08-23T00…
#> 3 uuid… 2019-08-22T13:1… Scott W… e249db9e… 2019-08-22T13:1… 2019-08-23T00…
#> 4 uuid… 2019-08-22T12:1… Scott W… e249db9e… 2019-08-22T12:1… 2019-08-23T00…
#> 5 uuid… 2019-08-22T12:0… Scott W… e249db9e… 2019-08-22T12:0… 2019-08-23T00…
#> 6 uuid… 2019-08-22T11:4… Scott W… e249db9e… 2019-08-22T11:4… 2019-08-23T00…
#> # … with 15 more variables: submitterId <chr>, submitterName <chr>,
#> #   instanceID <chr>, type <chr>, ...11 <dbl>, ...12 <dbl>, ...13 <dbl>,
#> #   accuracy <int>, species <chr>, sex <chr>, maturity <chr>,
#> #   activity <chr>, observer_acticity <chr>, photo_habitat <chr>,
#> #   .odata.context <chr>
```

A more detailed walk-through with some data visualisation examples is
available in the `vignette("odata", package="ruODK")` (online
[here](https://dbca-wa.github.io/ruODK/articles/odata.html)).

See also `vignette("restapi", package="ruODK")` (online
[here](https://dbca-wa.github.io/ruODK/articles/api.html)) for examples
using the alternative RESTful API.

## Contribute

Contributions through [issues](https://github.com/dbca-wa/ruODK/issues)
and PRs are welcome\!

## Release

These steps prepare a new `ruODK` release.

``` r
# Tests
devtools::test()

# Docs
styler::style_pkg()
devtools::document(roclets = c("rd", "collate", "namespace"))
spelling::spell_check_package()
spelling::update_wordlist()
codemetar::write_codemeta("ruODK")
usethis::edit_file("inst/CITATION")
rmarkdown::render('README.Rmd',  encoding = 'UTF-8')
if (fs::file_exists("README.html")) fs::file_delete("README.html")

# Checks
goodpractice::goodpractice(quiet = FALSE)
devtools::check()

# Release
usethis::use_version("minor")
usethis::edit_file("NEWS.md")
pkgdown::build_site()

# Vignettes are big
# the repo is small
# so what shall we do
# let's mogrify all
system("find vignettes/attachments/ -maxdepth 2 -type f -exec mogrify -resize 300x200 {} \\;")
vignette_tempfiles <- here::here("vignettes", "attachments")
fs::dir_copy(vignette_tempfiles, here::here("docs/articles/"))

# Git commit and push
```

## Attribution

`ruODK` was developed, and is maintained, by Florian Mayer for the
Western Australian [Department of Biodiversity, Conservation and
Attractions (DBCA)](https://www.dbca.wa.gov.au/). The development was
funded both by DBCA core funding and Offset funding through the [North
West Shelf Flatback Turtle Conservation
Program](https://flatbacks.dbca.wa.gov.au/).

## Citation

To cite package `ruODK` in publications use:

``` r
citation("ruODK")
#> 
#> To cite ruODK in publications use:
#> 
#>   Florian W. Mayer (2019). ruODK: Client for the ODK Central API.
#>   R package version 0.3.1. https://github.com/dbca-wa/ruODK
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Misc{,
#>     title = {ruODK: Client for the ODK Central API},
#>     author = {Florian W. Mayer},
#>     note = {R package version 0.3.1},
#>     year = {2019},
#>     url = {https://github.com/dbca-wa/ruODK},
#>   }
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
