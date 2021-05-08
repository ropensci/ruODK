
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `ruODK`: An R Client for the ODK Central API <img src="man/figures/ruODK2.png" align="right" alt="Especially in these trying times, it is important to ask: ruODK?" width="120" />

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3953158.svg)](https://doi.org/10.5281/zenodo.3953158)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Last-changedate](https://img.shields.io/github/last-commit/ropensci/ruODK.svg)](https://github.com/ropensci/ruODK/commits/main)
[![GitHub
issues](https://img.shields.io/github/issues/ropensci/ruodk.svg?style=popout)](https://github.com/ropensci/ruODK/issues/)
[![CI - GitHub
Actions](https://github.com/ropensci/ruODK/workflows/tic/badge.svg)](https://github.com/ropensci/ruODK/actions)
[![CI -
Appveyor](https://ci.appveyor.com/api/projects/status/1cs19xx0t64bmd2q/branch/master?svg=true)](https://ci.appveyor.com/project/florianm/ruodk/branch/main)
[![Text
coverage](https://codecov.io/gh/ropensci/ruODK/branch/main/graph/badge.svg)](https://codecov.io/gh/ropensci/ruODK)
[![CodeFactor](https://www.codefactor.io/repository/github/ropensci/ruodk/badge)](https://www.codefactor.io/repository/github/ropensci/ruodk)
[![Hosted RStudio with
ruODK](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/dbca-wa/urODK/master?urlpath=rstudio)
<!-- badges: end -->

Especially in these trying times, it is important to ask “r u ODK?”.

`ruODK` is an R client to access and parse data from ODK Central.

[OpenDataKit](https://getodk.org/) (ODK) is [free-and open-source
software](https://getodk.org/software/) that helps millions of people
collect data quickly, accurately, offline, and at scale. The software is
in active use in every country in the world and is supported by a large
and helpful community.

`ruODK` is a community contribution to the ODK ecosystem, but not
directly affiliated with ODK.

`ruODK` assumes some familiarity of its users with the ODK ecosystem and
workflows. For a detailed overview, read the extensive [ODK
documentation](https://docs.getodk.org/) and visit the friendly [ODK
forum](https://forum.getodk.org/).

[ODK Central](https://docs.getodk.org/central-intro/) is a cloud-based
data clearinghouse for digitally captured data, replacing the older
software [ODK Aggregate](https://docs.getodk.org/aggregate-intro/). ODK
Central manages user accounts and permissions, stores form definitions,
and allows data collection clients like [ODK
Collect](https://docs.getodk.org/collect-intro/) to connect to it for
form download and submission upload.

![An ODK setup with ODK Build, Central, Collect, and
ruODK](https://www.lucidchart.com/publicSegments/view/952c1350-3003-48c1-a2c8-94bad74cdb46/image.png)

A typical [ODK workflow](https://docs.getodk.org/#how-is-odk-used): An
XForm is designed e.g. in [ODK Build](https://build.getodk.org/),
[published to ODK Central](https://docs.getodk.org/central-forms/), and
downloaded onto an Android device running ODK Collect. After data have
been captured digitally using [ODK
Collect](https://docs.getodk.org/collect-intro/), the data are uploaded
and stored in ODK Central. The next step from there is to extract the
data, optionally upload it into another data warehouse, and then to
analyse and generate insight from it.

While data can be retrieved in bulk through the GUI, ODK Central’s API
provides access to its data and functionality through both an OData and
a RESTful API with a comprehensive and interactive
[documentation](https://odkcentral.docs.apiary.io/#reference/odata-endpoints).

`ruODK` is aimed at the technically minded researcher who wishes to
access and process data from ODK Central using the programming language
R.

Benefits of using the R ecosystem in combination with ODK:

-   Scalability: Both R and ODK are free and open source software.
    Scaling to many users does not incur license fees.
-   Ubiquity: R is known to many scientists and is widely taught at
    universities.
-   Automation: The entire data access and analysis workflow can be
    automated through R scripts.
-   Reproducible reporting (e.g. 
    [Sweave](https://support.rstudio.com/hc/en-us/articles/200552056-Using-Sweave-and-knitr),
    [RMarkdown](https://rmarkdown.rstudio.com/)), interactive web apps
    ([Shiny](https://shiny.rstudio.com/)), workflow scaling
    ([drake](https://docs.ropensci.org/drake/)).
-   Rstudio-as-a-Service (RaaS) at
    [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/dbca-wa/urODK/master?urlpath=rstudio)

`ruODK`’s scope:

-   To wrap all ODK Central API endpoints with a focus on **data
    access**.
-   To provide working examples of interacting with the ODK Central API.
-   To provide convenience helpers for the day to day tasks when working
    with ODK Central data in R: **data munging** the ODK Central API
    output into tidy R formats.

<!-- TODO: vignette "workflows" -->

`ruODK`’s use cases:

-   Smaller projects: Example
    [rOzCBI](https://dbca-wa.github.io/rOzCBI/)
    1.  Data collection: ODK Collect
    2.  Data clearinghouse: ODK Central
    3.  Data analysis and reporting: `Rmd` (ruODK)
    4.  Publishing and dissemination:
        [`ckanr`](https://docs.ropensci.org/ckanr/),
        [`CKAN`](https://ckan.org/)
-   Larger projects:
    1.  Data collection: ODK Collect
    2.  Data clearinghouse: ODK Central
    3.  ETL pipeline into data warehouses: `Rmd` (ruODK)
    4.  QA: in data warehouse
    5.  Reporting: `Rmd`
    6.  Publishing and dissemination:
        [`ckanr`](https://docs.ropensci.org/ckanr/),
        [`CKAN`](https://ckan.org/)

Out of scope:

-   To wrap “management” API endpoints. ODK Central is a [VueJS/NodeJS
    application](https://github.com/opendatakit/central-frontend/) which
    provides a comprehensive graphical user interface for the management
    of users, roles, permissions, projects, and forms.
-   To provide extensive data visualisation. We show only minimal
    examples of data visualisation and presentation, mainly to
    illustrate the example data. Once the data is in your hands as tidy
    tibbles… urODK!

## A quick preview

<img src="man/figures/odata.svg" alt="ruODK screencast" width="100%" />

## Install

You can install the development version (`main` branch) of `ruODK` with:

``` r
if (!requireNamespace("remotes")) install.packages("remotes")
remotes::install_github("ropensci/ruODK@main", dependencies = TRUE)
```

## ODK Central

### Access to an ODK Central instance

First, we need an ODK Central instance and some data to play with!

Either [request a free trial](https://getodk.org/#odk-cloud) or follow
the [setup instructions](https://docs.getodk.org/central-intro/) to
build and deploy your very own ODK Central instance.

### ODK Central setup

The ODK Central [user manual](https://docs.getodk.org/central-using/)
provides up-to-date descriptions of the steps below.

-   [Create a web user
    account](https://docs.getodk.org/central-users/#creating-a-web-user)
    on an ODK Central instance. Your username will be an email address.
-   [Create a project](https://docs.getodk.org/central-projects/) and
    give the web user at least [read
    permissions](https://docs.getodk.org/central-projects/#managing-project-managers).
-   Create an XForm, e.g. using ODK Build, or use the [example
    forms](https://github.com/ropensci/ruODK/tree/master/inst/extdata)
    provided by `ruODK`. The `.odkbuild` versions can be loaded into
    [ODK Build](https://build.getodk.org/), while the `.xml` versions
    can be directly imported into ODK Central.
-   [Publish the form](https://docs.getodk.org/central-forms/) to ODK
    Central.
-   Collect some data for this form on ODK Collect and let ODK Collect
    submit the finalised forms to ODK Central.

## Configure `ruODK`

Set up `ruODK` with an OData Service URL and credentials of a
read-permitted ODK Central web user. Adjust verbosity to your liking.

    #> <ruODK settings>
    #>   Default ODK Central Project ID: 2 
    #>   Default ODK Central Form ID: Flora-Quadrat-04 
    #>   Default ODK Central URL: https://odkc.dbca.wa.gov.au 
    #>   Default ODK Central Username: Florian.Mayer@dbca.wa.gov.au 
    #>   Default ODK Central Password: run ruODK::get_default_pw() to show 
    #>   Default ODK Central Passphrase: run ruODK::get_default_pp() to show 
    #>   Default Time Zone: Australia/Perth 
    #>   Default ODK Central Version: 1.1 
    #>   Default HTTP GET retries: 3 
    #>   Verbose messages: TRUE 
    #>   Test ODK Central Project ID: 2 
    #>   Test ODK Central Form ID: Flora-Quadrat-04 
    #>   Test ODK Central Form ID (ZIP tests): Spotlighting-06 
    #>   Test ODK Central Form ID (Attachment tests): Flora-Quadrat-04-att 
    #>   Test ODK Central Form ID (Parsing tests): Flora-Quadrat-04-gap 
    #>   Test ODK Central Form ID (WKT tests): Locations 
    #>   Test ODK Central URL: https://odkc.dbca.wa.gov.au 
    #>   Test ODK Central Username: Florian.Mayer@dbca.wa.gov.au 
    #>   Test ODK Central Password: run ruODK::get_test_pw() to show 
    #>   Test ODK Central Passphrase: run ruODK::get_test_pp() to show 
    #>   Test ODK Central Version: 1.1

``` r
ruODK::ru_setup(
  svc = "https://my.odkcentral.getodk.org/v1/projects/14/forms/myform.svc",
  un = "me@email.com",
  pw = "...",
  tz = "Australia/Perth",
  verbose = TRUE # great for demo or debugging
)
```

For all available detailed options to configure `ruODK`, read
[`vignette("setup", package = "ruODK")`](https://docs.ropensci.org/ruODK/articles/setup.html).

## Use ruODK

A quick example browsing projects, forms, submissions, and accessing the
data:

``` r
library(ruODK)
# Part 1: Data discovery ------------------------------------------------------#
# List projects
proj <- ruODK::project_list()
proj %>% head() %>% knitr::kable(.)
```

|  id | name                             | forms | last\_submission    | app\_users | created\_at         | updated\_at         | key\_id | archived |
|----:|:---------------------------------|------:|:--------------------|-----------:|:--------------------|:--------------------|--------:|:---------|
|   1 | DBCA                             |    12 | 2021-04-19 08:05:48 |         14 | 2020-09-15 11:50:06 | 2021-04-29 11:54:19 |      NA | FALSE    |
|   4 | Fire Management and Plant Health |     5 | 2020-11-06 11:47:21 |          2 | 2020-11-06 11:12:16 | 2020-11-06 11:43:20 |      NA | FALSE    |
|   6 | Kingston Spotlighting            |     3 | 2021-03-24 11:32:15 |          3 | 2021-02-16 14:01:19 | 2021-02-16 14:40:31 |      NA | FALSE    |
|   2 | ruODK package tests              |    12 | 2020-11-02 12:41:14 |          1 | 2020-10-31 19:11:50 | 2020-11-23 13:25:03 |      NA | FALSE    |
|   3 | ruODK package tests encrypted    |     1 | 2020-11-02 15:26:38 |          1 | 2020-10-31 19:12:57 | 2020-11-02 15:23:17 |       1 | FALSE    |
|   5 | Sandbox                          |     2 | 2021-04-09 18:34:33 |          1 | 2020-12-14 15:36:46 | 2020-12-16 11:16:29 |      NA | FALSE    |

``` r
# List forms of default project
frms <- ruODK::form_list()
frms %>% head() %>% knitr::kable(.)
```

| name                              | fid                     | version | state | submissions | created\_at         | created\_by\_id | created\_by   | updated\_at         | published\_at       | last\_submission    | hash                             |
|:----------------------------------|:------------------------|:--------|:------|:------------|:--------------------|----------------:|:--------------|:--------------------|:--------------------|:--------------------|:---------------------------------|
| Flora Quadrat 0.4                 | Flora-Quadrat-04        |         | open  | 1           | 2020-11-02 10:56:21 |               5 | Florian Mayer | 2020-11-23 13:25:03 | 2020-11-02 10:56:25 | 2020-11-02 12:19:45 | 434ff9e1e33fc8bb35148c0cc6979708 |
| Flora Quadrat 0.4 (gap)           | Flora-Quadrat-04-gap    |         | open  | 2           | 2020-11-02 11:15:29 |               5 | Florian Mayer | 2020-11-23 13:25:03 | 2020-11-02 11:15:32 | 2020-11-02 12:36:09 | 241c4759564ea039b4404b6892025500 |
| Flora Quadrat 0.4 (one att)       | Flora-Quadrat-04-att    |         | open  | 1           | 2020-11-02 11:13:13 |               5 | Florian Mayer | 2020-11-23 13:25:03 | 2020-11-02 11:13:16 | 2020-11-02 12:36:10 | 2cb6a4b3d7f05ab055f3da89d0958b14 |
| I8n label and choices             | I8n\_label\_choices     |         | open  | 2           | 2020-11-02 11:29:48 |               5 | Florian Mayer | 2020-11-23 13:25:03 | 2020-11-02 11:29:50 | 2020-11-02 12:41:14 | bc4dff584ab2e0b0dd2c50eb1c2c7aa4 |
| I8n label lang                    | I8n\_label\_lng         |         | open  | 1           | 2020-11-02 11:38:37 |               5 | Florian Mayer | 2020-11-23 13:25:03 | 2020-11-02 11:38:40 | 2020-11-02 12:39:58 | 7e912580b246796c8477cfcd4c5dceab |
| I8n label lang with choice filter | I8n\_lang\_choicefilter |         | open  | 0           | 2020-11-23 13:23:36 |               5 | Florian Mayer | 2020-11-23 13:25:03 | 2020-11-23 13:23:41 | NA                  | 369a921eb94672dabbd395a035819d65 |

``` r
# Form details of default form
frmd <- ruODK::form_detail()
frmd %>% knitr::kable(.)
```

| name              | fid              | version | state | submissions | created\_at              | created\_by\_id | created\_by   | updated\_at              | published\_at            | last\_submission         | hash                             |
|:------------------|:-----------------|:--------|:------|------------:|:-------------------------|----------------:|:--------------|:-------------------------|:-------------------------|:-------------------------|:---------------------------------|
| Flora Quadrat 0.4 | Flora-Quadrat-04 |         | open  |           1 | 2020-11-02T02:56:21.085Z |               5 | Florian Mayer | 2020-11-23T05:25:03.426Z | 2020-11-02T02:56:25.092Z | 2020-11-02T04:19:45.451Z | 434ff9e1e33fc8bb35148c0cc6979708 |

``` r
# Form schema: defaults to version 1.1
meta <- ruODK::form_schema(odkc_version = get_test_odkc_version())
#> ℹ Form schema v1.1
meta %>% knitr::kable(.)
```

| path                                                       | name                                  | type      | binary | ruodk\_name                                                |
|:-----------------------------------------------------------|:--------------------------------------|:----------|:-------|:-----------------------------------------------------------|
| /meta                                                      | meta                                  | structure | NA     | meta                                                       |
| /meta/instanceID                                           | instanceID                            | string    | NA     | meta\_instance\_id                                         |
| /encounter\_start\_datetime                                | encounter\_start\_datetime            | dateTime  | NA     | encounter\_start\_datetime                                 |
| /reporter                                                  | reporter                              | string    | NA     | reporter                                                   |
| /device\_id                                                | device\_id                            | string    | NA     | device\_id                                                 |
| /location                                                  | location                              | structure | NA     | location                                                   |
| /location/area\_name                                       | area\_name                            | string    | NA     | location\_area\_name                                       |
| /location/quadrat\_photo                                   | quadrat\_photo                        | binary    | TRUE   | location\_quadrat\_photo                                   |
| /location/corner1                                          | corner1                               | geopoint  | NA     | location\_corner1                                          |
| /habitat                                                   | habitat                               | structure | NA     | habitat                                                    |
| /habitat/morphological\_type                               | morphological\_type                   | select1   | NA     | habitat\_morphological\_type                               |
| /habitat/morphological\_type\_photo                        | morphological\_type\_photo            | binary    | TRUE   | habitat\_morphological\_type\_photo                        |
| /vegetation\_stratum                                       | vegetation\_stratum                   | repeat    | NA     | vegetation\_stratum                                        |
| /vegetation\_stratum/nvis\_level3\_broad\_floristic\_group | nvis\_level3\_broad\_floristic\_group | select1   | NA     | vegetation\_stratum\_nvis\_level3\_broad\_floristic\_group |
| /vegetation\_stratum/max\_height\_m                        | max\_height\_m                        | decimal   | NA     | vegetation\_stratum\_max\_height\_m                        |
| /vegetation\_stratum/foliage\_cover                        | foliage\_cover                        | select1   | NA     | vegetation\_stratum\_foliage\_cover                        |
| /vegetation\_stratum/dominant\_species\_1                  | dominant\_species\_1                  | string    | NA     | vegetation\_stratum\_dominant\_species\_1                  |
| /vegetation\_stratum/dominant\_species\_2                  | dominant\_species\_2                  | string    | NA     | vegetation\_stratum\_dominant\_species\_2                  |
| /vegetation\_stratum/dominant\_species\_3                  | dominant\_species\_3                  | string    | NA     | vegetation\_stratum\_dominant\_species\_3                  |
| /vegetation\_stratum/dominant\_species\_4                  | dominant\_species\_4                  | string    | NA     | vegetation\_stratum\_dominant\_species\_4                  |
| /perimeter                                                 | perimeter                             | structure | NA     | perimeter                                                  |
| /perimeter/corner2                                         | corner2                               | geopoint  | NA     | perimeter\_corner2                                         |
| /perimeter/corner3                                         | corner3                               | geopoint  | NA     | perimeter\_corner3                                         |
| /perimeter/corner4                                         | corner4                               | geopoint  | NA     | perimeter\_corner4                                         |
| /perimeter/mudmap\_photo                                   | mudmap\_photo                         | binary    | TRUE   | perimeter\_mudmap\_photo                                   |
| /taxon\_encounter                                          | taxon\_encounter                      | repeat    | NA     | taxon\_encounter                                           |
| /taxon\_encounter/field\_name                              | field\_name                           | string    | NA     | taxon\_encounter\_field\_name                              |
| /taxon\_encounter/photo\_in\_situ                          | photo\_in\_situ                       | binary    | TRUE   | taxon\_encounter\_photo\_in\_situ                          |
| /taxon\_encounter/taxon\_encounter\_location               | taxon\_encounter\_location            | geopoint  | NA     | taxon\_encounter\_taxon\_encounter\_location               |
| /taxon\_encounter/life\_form                               | life\_form                            | select1   | NA     | taxon\_encounter\_life\_form                               |
| /taxon\_encounter/voucher\_specimen\_barcode               | voucher\_specimen\_barcode            | barcode   | NA     | taxon\_encounter\_voucher\_specimen\_barcode               |
| /taxon\_encounter/voucher\_specimen\_label                 | voucher\_specimen\_label              | string    | NA     | taxon\_encounter\_voucher\_specimen\_label                 |
| /encounter\_end\_datetime                                  | encounter\_end\_datetime              | dateTime  | NA     | encounter\_end\_datetime                                   |

``` r
# Part 2: Data access ---------------------------------------------------------#
# Form tables
srv <- ruODK::odata_service_get()
srv %>% knitr::kable(.)
```

| name                            | kind      | url                             |
|:--------------------------------|:----------|:--------------------------------|
| Submissions                     | EntitySet | Submissions                     |
| Submissions.vegetation\_stratum | EntitySet | Submissions.vegetation\_stratum |
| Submissions.taxon\_encounter    | EntitySet | Submissions.taxon\_encounter    |

``` r
# Form submissions
data <- ruODK::odata_submission_get(local_dir = fs::path("vignettes/media"),
                                    odkc_version = get_test_odkc_version())
#> ℹ Downloading submissions...
#> ✔ Downloaded submissions.
#> ℹ Reading form schema...
#> ℹ Form schema v1.1
#> ℹ Parsing submissions...
#> ℹ Not unnesting geo fields: value_location_corner1, value_perimeter_corner2, value_perimeter_corner3, value_perimeter_corner4, value_taxon_encounter_taxon_encounter_location
#> ℹ Unnesting: value
#> ℹ Unnesting column "value"
#> ℹ Unnesting more list cols: value___system, value_meta, value_location, value_habitat, value_perimeter
#> ℹ Not unnesting geo fields: value_location_corner1, value_perimeter_corner2, value_perimeter_corner3, value_perimeter_corner4, value_taxon_encounter_taxon_encounter_location
#> ℹ Unnesting: value___system, value_meta, value_location, value_habitat, value_perimeter
#> ℹ Unnesting column "value___system"
#> ℹ Unnesting column "value_meta"
#> ℹ Unnesting column "value_location"
#> ℹ Unnesting column "value_habitat"
#> ℹ Unnesting column "value_perimeter"
#> ℹ Found date/times: encounter_start_datetime, encounter_end_datetime.
#> ℹ Found attachments in main Submissions table: location_quadrat_photo, habitat_morphological_type_photo, perimeter_mudmap_photo.
#> ℹ Downloading attachments...
#> ℹ Using local directory "vignettes/media".
#> ◉ File already downloaded, keeping "vignettes/media/1604290006239.jpg".
#> ℹ Using local directory "vignettes/media".
#> ◉ File already downloaded, keeping "vignettes/media/1604290049411.jpg".
#> ℹ Using local directory "vignettes/media".
#> ◉ File already downloaded, keeping "vignettes/media/1604290379613.jpg".
#> ℹ Found geopoints: location_corner1, perimeter_corner2, perimeter_corner3, perimeter_corner4.
#> ℹ Parsing location_corner1...
#> ℹ Parsing perimeter_corner2...
#> ℹ Parsing perimeter_corner3...
#> ℹ Parsing perimeter_corner4...
#> ℹ Found geotraces: .
#> ℹ Found geoshapes: .
#> ✔ Returning parsed submissions.
data %>% dplyr::select(-"odata_context") %>% knitr::kable(.)
```

| id                                        | encounter\_start\_datetime | device\_id       | encounter\_end\_datetime | system\_submission\_date | system\_submitter\_id | system\_submitter\_name | system\_attachments\_present | system\_attachments\_expected | meta\_instance\_id                        | location\_area\_name | location\_quadrat\_photo          | location\_corner1\_longitude | location\_corner1\_latitude | location\_corner1\_altitude | location\_corner1\_accuracy | location\_corner1                                            | habitat\_morphological\_type | habitat\_morphological\_type\_photo | vegetation\_stratum\_odata\_navigation\_link                                 | perimeter\_corner2\_longitude | perimeter\_corner2\_latitude | perimeter\_corner2\_altitude | perimeter\_corner2\_accuracy | perimeter\_corner2                                           | perimeter\_corner3\_longitude | perimeter\_corner3\_latitude | perimeter\_corner3\_altitude | perimeter\_corner3\_accuracy | perimeter\_corner3                                           | perimeter\_corner4\_longitude | perimeter\_corner4\_latitude | perimeter\_corner4\_altitude | perimeter\_corner4\_accuracy | perimeter\_corner4                                           | perimeter\_mudmap\_photo          | taxon\_encounter\_odata\_navigation\_link                                 |
|:------------------------------------------|:---------------------------|:-----------------|:-------------------------|:-------------------------|:----------------------|:------------------------|-----------------------------:|------------------------------:|:------------------------------------------|:---------------------|:----------------------------------|-----------------------------:|----------------------------:|----------------------------:|----------------------------:|:-------------------------------------------------------------|:-----------------------------|:------------------------------------|:-----------------------------------------------------------------------------|------------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|:-------------------------------------------------------------|------------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|:-------------------------------------------------------------|------------------------------:|-----------------------------:|-----------------------------:|-----------------------------:|:-------------------------------------------------------------|:----------------------------------|:--------------------------------------------------------------------------|
| uuid:469f71d3-d7aa-4c74-8aaa-af5f667a2f28 | 2020-11-02 12:06:19        | 5afb51f35ba0c572 | 2020-11-02 12:15:48      | 2020-11-02T04:19:45.451Z | 53                    | ruODK                   |                            5 |                             5 | uuid:469f71d3-d7aa-4c74-8aaa-af5f667a2f28 | Test site 1          | vignettes/media/1604290006239.jpg |                     115.8844 |                   -31.99596 |                       -12.7 |                       4.625 | Point , 115.8843989 , -31.9959554 , -12.6999998092651, 4.625 | flat                         | vignettes/media/1604290049411.jpg   | Submissions(‘uuid:469f71d3-d7aa-4c74-8aaa-af5f667a2f28’)/vegetation\_stratum |                      115.8843 |                    -31.99579 |                        -21.2 |                        4.861 | Point , 115.8842726 , -31.9957893 , -21.1999988555908, 4.861 |                      115.8843 |                    -31.99582 |                        -21.2 |                        4.655 | Point , 115.8843031 , -31.9958188 , -21.1999988555908, 4.655 |                      115.8846 |                    -31.99614 |                        -12.7 |                        4.913 | Point , 115.8845949 , -31.9961397 , -12.6999998092651, 4.913 | vignettes/media/1604290379613.jpg | Submissions(‘uuid:469f71d3-d7aa-4c74-8aaa-af5f667a2f28’)/taxon\_encounter |

A more detailed walk-through with some data visualisation examples is
available in the
[`vignette("odata-api", package="ruODK")`](https://docs.ropensci.org/ruODK/articles/odata-api.html).

See also
[`vignette("restful-api", package="ruODK")`](https://docs.ropensci.org/ruODK/articles/restful-api.html)
for examples using the alternative RESTful API.

## Try ruODK

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/dbca-wa/urODK/master?urlpath=rstudio)
will launch a disposable, hosted RStudio instance with `ruODK` installed
and the companion package [`urODK`](https://github.com/dbca-wa/urODK)
opened as starting point for a hands-on workshop or instant demo of
`ruODK` usage.

Create a new RMarkdown workbook from `ruODK` template “ODK Central via
OData” and follow the instructions within.

## Contribute

Contributions through [issues](https://github.com/ropensci/ruODK/issues)
and PRs are welcome!

See the [contributing
guide](https://docs.ropensci.org/ruODK/CONTRIBUTING.html) on best
practices and further readings for code contributions.

## Attribution

`ruODK` was developed, and is maintained, by Florian Mayer for the
Western Australian [Department of Biodiversity, Conservation and
Attractions (DBCA)](https://www.dbca.wa.gov.au/). The development was
funded both by DBCA core funding and external funds from the [North West
Shelf Flatback Turtle Conservation
Program](https://flatbacks.dbca.wa.gov.au/).

To cite package `ruODK` in publications use:

``` r
citation("ruODK")
#> 
#> To cite ruODK in publications use (with the respective version number:
#> 
#>   Mayer, Florian Wendelin. (2020, Nov 19).  ruODK: An R Client for the ODK Central API (Version 0.10.1).  Zenodo.
#>   https://doi.org/10.5281/zenodo.3953158
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Misc{,
#>     title = {ruODK: Client for the ODK Central API},
#>     author = {Florian W. Mayer},
#>     note = {R package version 0.10.1},
#>     year = {2020},
#>     url = {https://github.com/ropensci/ruODK},
#>   }
```

## Acknowledgements

The Department of Biodiversity, Conservation and Attractions (DBCA)
acknowledges the traditional owners of country throughout Western
Australia and their continuing connection to the land, waters and
community. We pay our respects to them, their culture and to their
Elders past and present.

This software was created both as a contribution to the ODK ecosystem
and for the conservation of the biodiversity of Western Australia, and
in doing so, caring for country.

## Package functionality

See
[`vignette("comparison", package="ruODK")`](https://docs.ropensci.org/ruODK/articles/comparison.html)
for a comprehensive comparison of ruODK to other software packages from
both an ODK and an OData angle.
