
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `ruODK`: An R Client for the ODK Central API <img src="man/figures/ruODK.png" align="right" alt="Are you ODK?" width="120" />

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
apps](https://opendatakit.org/software/). `ruODK` assumes some
familiarity of its users with the ODK ecosystem and workflows. For a
detailed overview, read the extensive [ODK
documentation](https://docs.opendatakit.org/) and visit the friendly
[ODK forum](https://forum.opendatakit.org/).

[ODK Central](https://docs.opendatakit.org/central-intro/) is a
cloud-based data clearinghouse for digitally captured data, replacing
the older software [ODK
Aggregate](https://docs.opendatakit.org/aggregate-intro/). ODK Central
manages user accounts and permissions, stores form definitions, and
allows data collection clients like [ODK
Collect](https://docs.opendatakit.org/collect-intro/) to connect to it
for form download and submission upload.

![An ODK setup with ODK Build, Central, Collect, and
ruODK](https://www.lucidchart.com/publicSegments/view/952c1350-3003-48c1-a2c8-94bad74cdb46/image.png)

A typical [ODK workflow](https://docs.opendatakit.org/#how-is-odk-used):
An XForm is designed e.g. in [ODK
Build](https://build.opendatakit.org/), [published to ODK
Central](https://docs.opendatakit.org/central-forms/), and downloaded
onto an Android device running ODK Collect. After data have been
captured digitally using [ODK
Collect](https://docs.opendatakit.org/collect-intro/), the data are
uploaded and stored in ODK Central. The next step from there is to
extract the data, optionally upload it into another data warehouse, and
then to analyse and generate insight from it.

While data can be retrieved in bulk through the GUI, ODK Central’s API
provides access to its data and functionality through both an OData and
a RESTful API with a comprehensive and interactive
[documentation](https://odkcentral.docs.apiary.io/#reference/odata-endpoints).

`ruODK` is aimed at the technically minded researcher who wishes to
access and use the data from ODK Central using the programming language
R.

Benefits of using the R ecosystem in combination with ODK:

  - Scalability: Both R and ODK are free and open source software.
    Scaling to many users does not incur license fees.
  - Ubiquity: R is known to many scientists and is widely taught at
    universities.
  - Automation: The entire data access workflow can be automated through
    R scripts.
  - Reproducible reporting (e.g. 
    [Sweave](https://support.rstudio.com/hc/en-us/articles/200552056-Using-Sweave-and-knitr),
    [RMarkdown](https://rmarkdown.rstudio.com/)), interactive web apps
    ([Shiny](https://shiny.rstudio.com/)), workflow scaling
    ([drake](https://docs.ropensci.org/drake/)) and a range of
    integrations with Docker (links coming soon).

`ruODK`’s scope:

  - To wrap all ODK Central API endpoints with a focus on **data
    access**.
  - To provide working examples of interacting with the ODK Central API.
  - To provide convenience helpers for the day to day tasks when working
    with ODK Central data in R: **data munging** the ODK Central API
    output into tidy R formats.

`ruODK`’s use cases:

  - Smaller projects:
    1.  Data collection: ODK Collect
    2.  Data clearinghouse: ODK Central
    3.  Data analysis and reporting: `Rmd` (ruODK)
    4.  Publishing and dissemination:
        [`ckanr`](https://docs.ropensci.org/ckanr/),
        [`CKAN`](https://ckan.org/)
  - Larger projects:
    1.  Data collection: ODK Collect
    2.  Data clearinghouse: ODK Central
    3.  ETL pipeline into data warehouses: `Rmd` (ruODK)
    4.  QA: in data warehouse
    5.  Reporting: `Rmd`
    6.  Publishing and dissemination:
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

### Access to an ODK Central instance

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
  - Create an Xform, e.g. using ODK Build, or use the provided example
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

## Configure `ruODK`

Set up `ruODK` with an OData Service URL and credentials of a
read-permitted ODK Central web user.

``` r
ruODK::ru_setup(
  svc="https://odkcentral.dbca.wa.gov.au/v1/projects/1/forms/build_Turtle-Sighting-0-1_1559790020.svc",
  # un = "me@email.com",
  # pw = "..."
)
```

For all available detailed options to configure `ruODK`, read
`vignette("Setup", package = "ruODK")` (online
[here](https://dbca-wa.github.io/ruODK/articles/setup.html)).

## Use ruODK

A quick example using the OData service:

``` r
library(ruODK)
# List projects
proj <- ruODK::project_list()
proj %>% knitr::kable(.)
```

| id | name    | forms | app\_users | last\_submission    | created\_at         | updated\_at         | archived |
| -: | :------ | ----: | ---------: | :------------------ | :------------------ | :------------------ | :------- |
|  1 | DBCA    |     9 |          1 | 2019-08-30 02:37:41 | 2019-06-05 09:12:44 | 2019-07-23 01:00:08 | FALSE    |
|  3 | Flora   |     1 |          1 | 2019-08-12 04:47:05 | 2019-06-06 03:24:31 | 2019-06-06 03:24:42 | FALSE    |
|  2 | Sandbox |     3 |          1 | 2019-06-26 07:12:25 | 2019-06-06 03:24:15 | 2019-08-28 11:25:26 | FALSE    |
|  4 | DBCA    |     0 |          0 | NA                  | 2019-06-27 02:54:30 | 2019-07-22 02:44:23 | TRUE     |

``` r

# List forms of default project
frms <- ruODK::form_list()
frms %>% knitr::kable(.)
```

| name                         | fid                                             | version | state   | submissions | created\_at         | created\_by\_id | created\_by   | updated\_at         | last\_submission    | hash                             |
| :--------------------------- | :---------------------------------------------- | :------ | :------ | :---------- | :------------------ | --------------: | :------------ | :------------------ | :------------------ | :------------------------------- |
| Flora Quadrat 0.4            | build\_Flora-Quadrat-0-4\_1564384341            |         | open    | 0           | 2019-07-29 07:13:48 |               5 | Florian Mayer | NA                  | NA                  | 1bb959d541ac6990e3f74893e38c855b |
| Marine Wildlife Incident 0.6 | build\_Marine-Wildlife-Incident-0-6\_1559789189 |         | open    | 5           | 2019-06-06 03:29:04 |               5 | Florian Mayer | NA                  | 2019-08-26 00:58:47 | ef79df7abb830de618d82765c36c2f59 |
| Predator or Disturbance 1.1  | build\_Predator-or-Disturbance-1-1\_1559789410  |         | open    | 14          | 2019-06-06 03:31:25 |               5 | Florian Mayer | NA                  | 2019-08-30 02:33:31 | 9c70919ed211e2492ff1dda7a6c7c564 |
| Site Visit End 0.2           | build\_Site-Visit-End-0-2\_1559789512           |         | open    | 32          | 2019-06-06 03:31:13 |               5 | Florian Mayer | NA                  | 2019-08-30 02:34:55 | 7b4d658b314cd1f0aef8c056c8d3009b |
| Site Visit Start 0.3         | build\_Site-Visit-Start-0-3\_1559789550         |         | open    | 32          | 2019-06-06 03:31:02 |               5 | Florian Mayer | NA                  | 2019-08-30 02:36:02 | 64e8fabc98ad20cd1eb1de62ac1d35c3 |
| Track Tally 0.5              | build\_Track-Tally-0-5\_1564032721              |         | closing | 2           | 2019-07-25 05:32:44 |               5 | Florian Mayer | 2019-07-29 07:57:44 | 2019-07-29 01:46:36 | 2d521c5b75c07238a5c55010efecf21b |
| Turtle Sighting 0.1          | build\_Turtle-Sighting-0-1\_1559790020          |         | open    | 150         | 2019-06-06 03:29:16 |               5 | Florian Mayer | NA                  | 2019-08-26 03:58:22 | dc5906a4a18c33ff0cfeee419b0ce00e |
| Turtle Track or Nest 1.0     | build\_Turtle-Track-or-Nest-1-0\_1559789920     |         | open    | 129         | 2019-06-06 03:30:36 |               5 | Florian Mayer | NA                  | 2019-08-30 02:37:41 | b52193af35826ff9da3678cc22469535 |
| Turtle Track Tally 0.6       | build\_Turtle-Track-Tally-0-6\_1564387009       |         | open    | 75          | 2019-07-29 07:57:36 |               5 | Florian Mayer | NA                  | 2019-08-30 02:36:38 | c293c4cc528738cdfb596e3b9732c66f |

``` r

# Form details of default form
frmd <- ruODK::form_detail()
frmd %>% knitr::kable(.)
```

| name                | fid                                    | version | state | submissions | created\_at              | created\_by\_id | created\_by   | updated\_at | last\_submission         | hash                             |
| :------------------ | :------------------------------------- | :------ | :---- | ----------: | :----------------------- | --------------: | :------------ | :---------- | :----------------------- | :------------------------------- |
| Turtle Sighting 0.1 | build\_Turtle-Sighting-0-1\_1559790020 |         | open  |         150 | 2019-06-06T03:29:16.497Z |               5 | Florian Mayer | NA          | 2019-08-26T03:58:22.016Z | dc5906a4a18c33ff0cfeee419b0ce00e |

``` r

# Form schema
meta <- ruODK::odata_metadata_get()
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

# Form submissions (sensitive data omitted)
data <- ruODK::odata_submission_get() %>%
  ruODK::odata_submission_parse()
data %>% 
  head(.) %>% 
  dplyr::select(-"reporter", -"...11") %>%
  knitr::kable(.)
```

| .\_\_id                                   | observation\_start\_time      | device\_id       | observation\_end\_time        | submissionDate           | submitterId | submitterName | instanceID                                | type  |        …12 |   …13 | accuracy | species           | sex | maturity       | activity     | observer\_acticity | photo\_habitat | .odata.context                                                                                                         |
| :---------------------------------------- | :---------------------------- | :--------------- | :---------------------------- | :----------------------- | :---------- | :------------ | :---------------------------------------- | :---- | ---------: | ----: | -------: | :---------------- | :-- | :------------- | :----------- | :----------------- | :------------- | :--------------------------------------------------------------------------------------------------------------------- |
| uuid:4cab20c1-4d04-4450-a76d-aaa6cfc02b35 | 2019-08-23T15:23:35.052+08:00 | e249db9e68907e41 | 2019-08-23T15:24:17.055+08:00 | 2019-08-26T03:58:22.016Z | 16          | Turtles       | uuid:4cab20c1-4d04-4450-a76d-aaa6cfc02b35 | Point | \-18.03410 |   4.1 |       10 | natator-depressus | na  | adult          | non-breeding | net-catch-failed   | NA             | <https://odkcentral.dbca.wa.gov.au/v1/projects/1/forms/build_Turtle-Sighting-0-1_1559790020.svc/$metadata#Submissions> |
| uuid:618e23a0-d5fb-45f3-b3d5-d669eca4b3e2 | 2019-08-23T15:18:31.267+08:00 | e249db9e68907e41 | 2019-08-23T15:18:56.466+08:00 | 2019-08-26T03:58:21.146Z | 16          | Turtles       | uuid:618e23a0-d5fb-45f3-b3d5-d669eca4b3e2 | Point | \-18.03370 |  42.6 |       10 | natator-depressus | na  | adult          | non-breeding | net-catch-failed   | NA             | <https://odkcentral.dbca.wa.gov.au/v1/projects/1/forms/build_Turtle-Sighting-0-1_1559790020.svc/$metadata#Submissions> |
| uuid:3877e264-1c1d-45d5-a2af-34267bf2a320 | 2019-08-23T15:17:41.789+08:00 | e249db9e68907e41 | 2019-08-23T15:18:09.073+08:00 | 2019-08-26T03:58:20.249Z | 16          | Turtles       | uuid:3877e264-1c1d-45d5-a2af-34267bf2a320 | Point | \-18.03323 |  46.6 |       10 | natator-depressus | na  | adult          | non-breeding | net-catch-failed   | NA             | <https://odkcentral.dbca.wa.gov.au/v1/projects/1/forms/build_Turtle-Sighting-0-1_1559790020.svc/$metadata#Submissions> |
| uuid:752e4d0c-dfac-4110-8adc-41f1898fbd4c | 2019-08-23T14:29:56.720+08:00 | e249db9e68907e41 | 2019-08-23T14:30:24.446+08:00 | 2019-08-26T03:58:19.479Z | 16          | Turtles       | uuid:752e4d0c-dfac-4110-8adc-41f1898fbd4c | Point | \-18.03521 | \-7.2 |       10 | natator-depressus | na  | adult          | non-breeding | no-interaction     | NA             | <https://odkcentral.dbca.wa.gov.au/v1/projects/1/forms/build_Turtle-Sighting-0-1_1559790020.svc/$metadata#Submissions> |
| uuid:c295b83a-4208-48be-b55e-e581ebd3eb75 | 2019-08-23T14:21:18.958+08:00 | e249db9e68907e41 | 2019-08-23T14:21:57.573+08:00 | 2019-08-26T03:58:18.755Z | 16          | Turtles       | uuid:c295b83a-4208-48be-b55e-e581ebd3eb75 | Point | \-18.03506 | \-4.1 |       10 | natator-depressus | na  | post-hatchling | non-breeding | net-catch-failed   | NA             | <https://odkcentral.dbca.wa.gov.au/v1/projects/1/forms/build_Turtle-Sighting-0-1_1559790020.svc/$metadata#Submissions> |
| uuid:09a1a70d-2beb-4766-b8bc-05b7362faf8a | 2019-08-23T14:11:48.456+08:00 | e249db9e68907e41 | 2019-08-23T14:12:08.446+08:00 | 2019-08-26T03:58:18.104Z | 16          | Turtles       | uuid:09a1a70d-2beb-4766-b8bc-05b7362faf8a | Point | \-18.03542 |   4.7 |       10 | natator-depressus | na  | adult          | non-breeding | no-interaction     | NA             | <https://odkcentral.dbca.wa.gov.au/v1/projects/1/forms/build_Turtle-Sighting-0-1_1559790020.svc/$metadata#Submissions> |

A more detailed walk-through with some data visualisation examples is
available in the `vignette("odata", package="ruODK")` (online
[here](https://dbca-wa.github.io/ruODK/articles/odata.html)).

See also `vignette("restapi", package="ruODK")` (online
[here](https://dbca-wa.github.io/ruODK/articles/api.html)) for examples
using the alternative RESTful API.

## Contribute

Contributions through [issues](https://github.com/dbca-wa/ruODK/issues)
and PRs are welcome\!

See the [contributing
guide](https://dbca-wa.github.io/ruODK/CONTRIBUTING.html) on best
practices and further readings for code contributions.

## Attribution

`ruODK` was developed, and is maintained, by Florian Mayer for the
Western Australian [Department of Biodiversity, Conservation and
Attractions (DBCA)](https://www.dbca.wa.gov.au/). The development was
funded both by DBCA core funding and Offset funding through the [North
West Shelf Flatback Turtle Conservation
Program](https://flatbacks.dbca.wa.gov.au/).

To cite package `ruODK` in publications use:

``` r
citation("ruODK")
#> 
#> To cite ruODK in publications use:
#> 
#>   Florian W. Mayer (2019). ruODK: Client for the ODK Central API.
#>   R package version 0.6.1. https://github.com/dbca-wa/ruODK
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Misc{,
#>     title = {ruODK: Client for the ODK Central API},
#>     author = {Florian W. Mayer},
#>     note = {R package version 0.6.1},
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
