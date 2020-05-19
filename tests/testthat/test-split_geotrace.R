test_that("split_geotrace works with numeric coordinates", {
  library(magrittr)
  data("geo_fs")
  data("geo_wkt_raw")
  data("geo_gj_raw")

  # Find variable names of geotraces
  geo_fields <- geo_fs %>%
    dplyr::filter(type  == "geotrace") %>%
    magrittr::extract2("ruodk_name")
  geo_fields[1] # First geotrace in data: path_location_path_gps

  # Rectangle but don't parse submission data (GeoJSON and WKT)
  geo_gj_rt <- geo_gj_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)
  geo_wkt_rt <- geo_wkt_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)

  # GeoJSON data with first geotrace split
  gj_first_gt <- split_geotrace(geo_gj_rt, geo_fields[1], wkt = FALSE)
  expect_true("path_location_path_gps_longitude" %in% names(gj_first_gt))
  expect_true("path_location_path_gps_latitude" %in% names(gj_first_gt))
  expect_true("path_location_path_gps_altitude" %in% names(gj_first_gt))
  expect_true(is.numeric(gj_first_gt$path_location_path_gps_longitude))
  expect_true(is.numeric(gj_first_gt$path_location_path_gps_latitude))
  expect_true(is.numeric(gj_first_gt$path_location_path_gps_altitude))

  # WKT data with first geotrace split
  wkt_first_gt <- split_geotrace(geo_wkt_rt, geo_fields[1], wkt = TRUE)
  expect_true("path_location_path_gps_longitude" %in% names(wkt_first_gt))
  expect_true("path_location_path_gps_latitude" %in% names(wkt_first_gt))
  expect_true("path_location_path_gps_altitude" %in% names(wkt_first_gt))
  expect_true(is.numeric(wkt_first_gt$path_location_path_gps_longitude))
  expect_true(is.numeric(wkt_first_gt$path_location_path_gps_latitude))
  expect_true(is.numeric(wkt_first_gt$path_location_path_gps_altitude))
})

# usethis::use_r("split_geotrace")