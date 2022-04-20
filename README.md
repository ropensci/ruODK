
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
[![Test
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

  - Scalability: Both R and ODK are free and open source software.
    Scaling to many users does not incur license fees.
  - Ubiquity: R is known to many scientists and is widely taught at
    universities.
  - Automation: The entire data access and analysis workflow can be
    automated through R scripts.
  - Reproducible reporting (e.g. 
    [Sweave](https://support.rstudio.com/hc/en-us/articles/200552056-Using-Sweave-and-knitr),
    [RMarkdown](https://rmarkdown.rstudio.com/)), interactive web apps
    ([Shiny](https://shiny.rstudio.com/)), workflow scaling
    ([drake](https://docs.ropensci.org/drake/)).
  - Rstudio-as-a-Service (RaaS) at
    [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/dbca-wa/urODK/master?urlpath=rstudio)

`ruODK`’s scope:

  - To wrap all ODK Central API endpoints with a focus on **data
    access**.
  - To provide working examples of interacting with the ODK Central API.
  - To provide convenience helpers for the day to day tasks when working
    with ODK Central data in R: **data munging** the ODK Central API
    output into tidy R formats.

<!-- TODO: vignette "workflows" -->

`ruODK`’s use cases:

  - Smaller projects: Example
    [rOzCBI](https://dbca-wa.github.io/rOzCBI/)
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

  - To wrap “management” API endpoints. ODK Central is a [VueJS/NodeJS
    application](https://github.com/getodk/central-frontend/) which
    provides a comprehensive graphical user interface for the management
    of users, roles, permissions, projects, and forms.
  - To provide extensive data visualisation. We show only minimal
    examples of data visualisation and presentation, mainly to
    illustrate the example data. Once the data is in your hands as tidy
    tibbles… urODK\!

## A quick preview

<img src="man/figures/odata.svg" alt="ruODK screencast" width="100%" />

## Install

You can install the latest release of `ruODK` from the [rOpenSci
R-Universe](https://ropensci.r-universe.dev):

``` r
# Enable the rOpenSci universe
options(repos = c(ropensci = 'https://ropensci.r-universe.dev',
                  CRAN = 'https://cloud.r-project.org'))
install.packages('ruODK')
```

Alternatively, you can install the development version from the `main`
branch.

``` r
if (!requireNamespace("remotes")) install.packages("remotes")
# Full install
remotes::install_github(
   "ropensci/ruODK@main", 
   dependencies = TRUE, 
   upgrade = "always",
   build_vignettes = TRUE)

# Minimal install without vignettes
remotes::install_github(
   "ropensci/ruODK@main", 
   dependencies = TRUE, 
   upgrade = "ask",
   build_vignettes = FALSE)
```

If the install fails, read the error messages carefully and install any
unmet dependencies (system libraries or R packages).

If the install fails on building the vignettes, you can set
`build_vignettes=FALSE` and read the vignettes from the online docs
instead.

If the installation still fails, or the above does not make any sense,
feel free to submit a [bug
report](https://github.com/ropensci/ruODK/issues/new/choose).

You can also run `ruODK` using Docker.

There are two ways to get the Docker image:

  - Download the pre-built [ruODK Docker
    image](https://github.com/ropensci/ruODK/pkgs/container/ruodk) or
  - build the image locally with your own GitHub Personal Access Token
    (PAT).

<!-- end list -->

    # Download
    docker pull ghcr.io/ropensci/ruodk:latest
    
    # Build
    git clone git@github.com:ropensci/ruODK.git
    cd ruODK
    docker build . -t <myorg>/ruodk:latest --build-arg GITHUB_PAT="..."

Then you can run the image in three ways:

  - RStudio Server running on <http://0.0.0.0:8787/> as user `rstudio`
    with a chosen password (here: `ruodk`),
  - with a Bash shell (from within you can run R or poke around in the
    system), or
  - with an R shell.

<!-- end list -->

    # RStudio Server
    docker run -e PASSWORD=ruodk -p 8787:8787 ghcr.io/ropensci/ruodk:latest
    
    # Bash shell
    docker run -it ghcr.io/ropensci/ruodk:latest /bin/bash -c "export TERM=xterm; exec bash"
    
    # R shell
    docker run -it ghcr.io/ropensci/ruodk:latest /bin/bash -c "export TERM=xterm; exec R"

If you don’t want to install and run Docker yourself, you can use the
hosted version on [BinderHub](https://mybinder.readthedocs.io/) by
clicking on
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/dbca-wa/urODK/master?urlpath=rstudio).

## ODK Central

### Access to an ODK Central instance

First, we need an ODK Central instance and some data to play with\!

Either [request a free trial](https://getodk.org/#odk-cloud) or follow
the [setup instructions](https://docs.getodk.org/central-intro/) to
build and deploy your very own ODK Central instance.

### ODK Central setup

The ODK Central [user manual](https://docs.getodk.org/central-using/)
provides up-to-date descriptions of the steps below.

  - [Create a web user
    account](https://docs.getodk.org/central-users/#creating-a-web-user)
    on an ODK Central instance. Your username will be an email address.
  - [Create a project](https://docs.getodk.org/central-projects/) and
    give the web user at least [read
    permissions](https://docs.getodk.org/central-projects/#managing-project-managers).
  - Create an XForm, e.g. using ODK Build, or use the [example
    forms](https://github.com/ropensci/ruODK/tree/master/inst/extdata)
    provided by `ruODK`. The `.odkbuild` versions can be loaded into
    [ODK Build](https://build.getodk.org/), while the `.xml` versions
    can be directly imported into ODK Central.
  - [Publish the form](https://docs.getodk.org/central-forms/) to ODK
    Central.
  - Collect some data for this form on ODK Collect and let ODK Collect
    submit the finalised forms to ODK Central.

## Configure `ruODK`

For all available detailed options to configure authentication for
`ruODK`, read [`vignette("setup", package =
"ruODK")`](https://docs.ropensci.org/ruODK/articles/setup.html).

## Use ruODK

A detailed walk-through with some data visualisation examples is
available in the [`vignette("odata-api",
package="ruODK")`](https://docs.ropensci.org/ruODK/articles/odata-api.html).

See also [`vignette("restful-api",
package="ruODK")`](https://docs.ropensci.org/ruODK/articles/restful-api.html)
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
and PRs are welcome\!

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
#>   Mayer, Florian Wendelin. (2020, Nov 19).  ruODK: An R Client for the
#>   ODK Central API (Version X.X.X).  Zenodo.
#>   https://doi.org/10.5281/zenodo.3953158
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Misc{,
#>     title = {ruODK: Client for the ODK Central API},
#>     author = {Florian W. Mayer},
#>     note = {R package version X.X.X},
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

This software was created on Whadjuk boodja (ground) both as a
contribution to the ODK ecosystem and for the conservation of the
biodiversity of Western Australia, and in doing so, caring for country.

## Package functionality

See [`vignette("comparison",
package="ruODK")`](https://docs.ropensci.org/ruODK/articles/comparison.html)
for a comprehensive comparison of ruODK to other software packages from
both an ODK and an OData angle.
