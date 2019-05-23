## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(DT)
library(leaflet)
library(magrittr)
library(tibble)
library(tidyr)
library(ruODK)

## ----sys_config, eval=F--------------------------------------------------
#  Sys.setenv(ODKC_UN="...@...")
#  Sys.setenv(ODKC_PW=".......")

## ----odk_config----------------------------------------------------------
# ODK Central credentials
if (file.exists("~/.Rprofile")) source("~/.Rprofile")

# ODK Central
odk_central <- "https://sandbox.central.opendatakit.org/"
project_id <- 14
form_id <- "build_Flora-Quadrat-0-2_1558575936"

base_url <- glue::glue("{odk_central}v1/projects/{project_id}/forms/")
data_url <- glue::glue("{base_url}{form_id}.svc")

## ----load_odata, eval=F--------------------------------------------------
#  fq_meta <- get_metadata(data_url)
#  fq_raw <- get_submissions(data_url)

## ----transform_data, message=T-------------------------------------------
pth <- "docs/articles/attachments"

fq_data <- tibble::tibble(value=fq_raw$value) %>% 
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
    longitude_c4=`...1`, latitude_c4=`...2`, altitude_c4=`...3` ) %>% 
  dplyr::mutate(
    quadrat_photo = get_attachment(base_url, form_id, uuid, quadrat_photo, local_dir = pth),
    morphological_type_photo = get_attachment(base_url, form_id, uuid, morphological_type_photo, local_dir = pth),
    mudmap_photo = get_attachment(base_url, form_id, uuid, mudmap_photo, local_dir = pth)
  ) %>% 
  invisible

## ----vis_data------------------------------------------------------------
DT::datatable(fq_data)

## ----map_data------------------------------------------------------------
leaflet::leaflet(width = 800, height = 600) %>%
  leaflet::addProviderTiles("OpenStreetMap.Mapnik", group = "Place names") %>%
  leaflet::addProviderTiles("Esri.WorldImagery", group = "Aerial") %>%
  leaflet::clearBounds() %>% 
  leaflet::addAwesomeMarkers(
    data = fq_data,
    lng = ~longitude, lat = ~latitude,
    icon = leaflet::makeAwesomeIcon(text = "Q", markerColor = "red"),
    label = ~glue::glue('{area_name} {encounter_start_datetime}'),
    popup = ~glue::glue(
      "<h3>{area_name}</h3>",
      "Survey start {encounter_start_datetime}</br>",
      "Reporter {reporter}</br>",
      "Device {device_id}</br>",
      "<h5>Site</h5>",
      '<div><img src="{quadrat_photo}"',
      ' height="150px" alt="Quadrat photo"></img></div>',
      "<h5>Mudmap</h5>",
      '<div><img src="{mudmap_photo}',
      ' height="150px" alt="Mudmap"></img></div>',
      "<h5>Habitat</h5>",
      "Morphological type: {morphological_type}</br>",
      '<div><img src="{morphological_type_photo}"',
      'height="150px" alt="Morphological type"></img></div>',
      "Veg class: {vegclass_placeholder}</br>"
    ),
    clusterOptions = leaflet::markerClusterOptions()
  ) %>%
  leaflet::addLayersControl(
    baseGroups = c("Place names", "Aerial"),
    options = leaflet::layersControlOptions(collapsed = FALSE)
  )

