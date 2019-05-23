
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

A note on the included example forms: The `.odkbuild` versions can be
loaded into [ODK Build](https://build.opendatakit.org/), while the
`.xml` versions can be imported into ODK Central.

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
if (file.exists("~/.Rprofile")) source("~/.Rprofile")

base_url <- "https://sandbox.central.opendatakit.org/v1/projects/14/forms/"
form_id <- "build_Flora-Quadrat-0-1_1558330379"
data_url <- glue::glue("{base_url}{form_id}.svc")

metadata <- get_metadata(data_url)

data_raw <- get_submissions(data_url)
data <- tibble::tibble(value=data_raw$value) %>% 
  tidyr::unnest_wider(value) %>% 
  dplyr::rename(uuid=`__id`) %>% 
  tidyr::unnest_wider(`__system`) %>% 
  tidyr::unnest_wider(meta) %>% 
  tidyr::unnest_wider(location) %>% 
  tidyr::unnest_wider(corner1) %>% 
  tidyr::unnest_wider(coordinates) %>% 
  dplyr::rename(longitude=`...1`, latitude=`...2`, altitude=`...3`) %>% 
  dplyr::select(-"type") %>% 
  tidyr::unnest_wider(habitat) %>%   
  tidyr::unnest_wider(vegetation_structure) %>%   
  tidyr::unnest_wider(perimeter) %>% 
  tidyr::unnest_wider(corner2) %>% 
  tidyr::unnest_wider(coordinates) %>%
  dplyr::select(-"type") %>% 
  dplyr::rename(
    longitude_c2=`...1`, latitude_c2=`...2`, altitude_c2=`...3`) %>% 
  tidyr::unnest_wider(corner3) %>% 
  tidyr::unnest_wider(coordinates) %>%
  dplyr::select(-"type") %>% 
  dplyr::rename(
    longitude_c3=`...1`, latitude_c3=`...2`, altitude_c3=`...3`) %>% 
  tidyr::unnest_wider(corner4) %>% 
  tidyr::unnest_wider(coordinates) %>%
  dplyr::select(-"type") %>% 
  dplyr::rename(
    longitude_c4=`...1`, latitude_c4=`...2`, altitude_c4=`...3`) %>%
  dplyr::mutate(
    quadrat_photo_local = dl_attachment(
      base_url, form_id, uuid, quadrat_photo),
    morphological_type_photo_local = dl_attachment(
      base_url, form_id, uuid, morphological_type_photo),
    mudmap_photo_local = dl_attachment(
      base_url, form_id, uuid, mudmap_photo)
  )
```

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
