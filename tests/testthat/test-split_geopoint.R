test_that("split_geopoint works with integer coordinates", {
  df <- tibble::tibble(
    stuff = c("asd", "sdf", "sdf"),
    loc = c(
      "POINT (115 -32 20)",
      "POINT (116 -33 15)",
      "POINT (114 -31 23)"
    )
  )
  df_split <- df %>% split_geopoint("loc", wkt = TRUE)
  testthat::expect_equal(
    names(df_split),
    c("stuff", "loc", "loc_longitude", "loc_latitude", "loc_altitude")
  )
  testthat::expect_true(is.numeric(df_split$loc_latitude))
  testthat::expect_true(is.numeric(df_split$loc_longitude))
  testthat::expect_true(is.numeric(df_split$loc_altitude))
})


test_that("split_geopoint works with numeric coordinates", {
  df <- tibble::tibble(
    stuff = c("asd", "sdf", "sdf"),
    loc = c(
      "POINT (115.99 -32.12 20.01)",
      "POINT (116.12 -33.34 15.23)",
      "POINT (114.00 -31.56 23.56)"
    )
  )
  df_split <- df %>% split_geopoint("loc", wkt = TRUE)
  testthat::expect_equal(
    names(df_split),
    c("stuff", "loc", "loc_longitude", "loc_latitude", "loc_altitude")
  )

  testthat::expect_true(is.numeric(df_split$loc_latitude))
  testthat::expect_true(is.numeric(df_split$loc_longitude))
  testthat::expect_true(is.numeric(df_split$loc_altitude))
})

test_that("split_geotrace works with numeric coordinates", {
  library(magrittr)
  data("geo_fs")
  data("geo_wkt_raw")
  data("geo_gj_raw")

  # Find variable names of geopoint
  geo_fields <- geo_fs %>%
    dplyr::filter(type  == "geopoint") %>%
    magrittr::extract2("ruodk_name")
  geo_fields[1] # First geopoint in data: path_location_path_gps

  # Rectangle but don't parse submission data (GeoJSON and WKT)
  geo_gj_rt <- geo_gj_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)
  geo_wkt_rt <- geo_wkt_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)

  # GeoJSON data with first geopoint split
  gj_first_gt <- split_geopoint(geo_gj_rt, geo_fields[1], wkt = FALSE)
  expect_true("point_location_point_gps_longitude" %in% names(gj_first_gt))
  expect_true("point_location_point_gps_latitude" %in% names(gj_first_gt))
  expect_true("point_location_point_gps_altitude" %in% names(gj_first_gt))
  expect_true(is.numeric(gj_first_gt$point_location_point_gps_longitude))
  expect_true(is.numeric(gj_first_gt$point_location_point_gps_latitude))
  expect_true(is.numeric(gj_first_gt$point_location_point_gps_altitude))

  # WKT data with first geopoint split
  wkt_first_gt <- split_geopoint(geo_wkt_rt, geo_fields[1], wkt = TRUE)
  expect_true("point_location_point_gps_longitude" %in% names(wkt_first_gt))
  expect_true("point_location_point_gps_latitude" %in% names(wkt_first_gt))
  expect_true("point_location_point_gps_altitude" %in% names(wkt_first_gt))
  expect_true(is.numeric(wkt_first_gt$point_location_point_gps_longitude))
  expect_true(is.numeric(wkt_first_gt$point_location_point_gps_latitude))
  expect_true(is.numeric(wkt_first_gt$point_location_point_gps_altitude))
})

# usethis::use_r("split_geopoint")
