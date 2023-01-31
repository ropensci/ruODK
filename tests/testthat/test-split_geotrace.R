test_that("split_geotrace works with GeoJSON", {
  data("geo_fs")
  data("geo_gj_raw")

  # Find variable names of geotraces
  geo_fields <- geo_fs %>%
    dplyr::filter(type == "geotrace") %>%
    magrittr::extract2("ruodk_name")

  # Rectangle but don't parse submission data (GeoJSON and WKT)
  geo_gj_rt <- geo_gj_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)

  # GeoJSON data with first geotrace split
  gj_first_gt <- split_geotrace(
    geo_gj_rt,
    geo_fields[1],
    wkt = FALSE,
    odkc_version = get_test_odkc_version()
  )

  expect_true(
    geo_fields[1] %in% names(gj_first_gt),
    label = "split_geotrace retains original GeoJSON field"
  )

  geofield_lon_gt <- glue::glue("{geo_fields[1]}_longitude")
  geofield_lat_gt <- glue::glue("{geo_fields[1]}_latitude")
  geofield_alt_gt <- glue::glue("{geo_fields[1]}_altitude")

  expect_true(
    geofield_lon_gt %in% names(gj_first_gt),
    label = "split_geotrace extracts GeoJSON longitude"
  )
  expect_true(
    geofield_lat_gt %in% names(gj_first_gt),
    label = "split_geotrace extracts GeoJSON latitude"
  )
  expect_true(
    geofield_alt_gt %in% names(gj_first_gt),
    label = "split_geotrace extracts GeoJSON altitude"
  )



  expect_true(
    gj_first_gt %>% magrittr::extract2(geofield_lon_gt) %>% is.numeric(),
    label = "split_geotrace casts extracted GeoJSON longitude to numeric"
  )
  expect_true(
    gj_first_gt %>% magrittr::extract2(geofield_lat_gt) %>% is.numeric(),
    label = "split_geotrace casts extracted GeoJSON latitude to numeric"
  )
  expect_true(
    gj_first_gt %>% magrittr::extract2(geofield_alt_gt) %>% is.numeric(),
    label = "split_geotrace casts extracted GeoJSON altitude to numeric"
  )
})

test_that("split_geotrace works with WKT", {
  data("geo_fs")
  data("geo_wkt_raw")

  # Find variable names of geotraces
  geo_fields <- geo_fs %>%
    dplyr::filter(type == "geotrace") %>%
    magrittr::extract2("ruodk_name")

  # Rectangle but don't parse submission data (GeoJSON and WKT)
  geo_wkt_rt <- geo_wkt_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)

  # GeoJSON data with first geotrace split
  wkt_first_gt <- split_geotrace(
    geo_wkt_rt,
    geo_fields[1],
    wkt = TRUE,
    odkc_version = get_test_odkc_version()
  )

  expect_true(
    geo_fields[1] %in% names(wkt_first_gt),
    label = "split_geotrace retains original WKT field"
  )

  geofield_lon <- glue::glue("{geo_fields[1]}_longitude")
  geofield_lat <- glue::glue("{geo_fields[1]}_latitude")
  geofield_alt <- glue::glue("{geo_fields[1]}_altitude")

  expect_true(
    geofield_lon %in% names(wkt_first_gt),
    label = "split_geotrace extracts WKT longitude"
  )
  expect_true(
    geofield_lat %in% names(wkt_first_gt),
    label = "split_geotrace extracts WKT latitude"
  )
  expect_true(
    geofield_alt %in% names(wkt_first_gt),
    label = "split_geotrace extracts WKT altitude"
  )

  expect_true(
    wkt_first_gt %>% magrittr::extract2(geofield_lon) %>% is.numeric(),
    label = "split_geotrace casts extracted WKT longitude to numeric"
  )
  expect_true(
    wkt_first_gt %>% magrittr::extract2(geofield_lat) %>% is.numeric(),
    label = "split_geotrace casts extracted WKT latitude to numeric"
  )
  expect_true(
    wkt_first_gt %>% magrittr::extract2(geofield_alt) %>% is.numeric(),
    label = "split_geotrace casts extracted WKT altitude to numeric"
  )
})

test_that("split_geotrace works with no data", {
  odk_empty <- tibble::tibble()
  odk_split <- split_geotrace(odk_empty, "tx")
  expect_s3_class(odk_split, class = c("tbl_df", "tbl", "data.frame"))
})

test_that("split_geotrace works with ODK Linestrings", {
  # ODK Central v0.7 and lower ignore the WKT argument for geotrace and geoshape
  # nolint start
  # ruODK::odata_submission_get(wkt = TRUE, parse = TRUE)
  # ruODK::odata_submission_get(wkt = FALSE, parse = FALSE) %>%
  # ruODK::odata_submission_rectangle()
  # First three points shown with truncated decimal places
  # nolint end
  odk_v7 <- tibble::tibble(
    id = 1,
    tx = "-14.80 128.40 10.9 5.9;-14.81 128.41 1.7 1.9;-14.82 128.42 1.9 1.7;"
  )
  odk_v7_split <- split_geotrace(odk_v7, "tx", odkc_version = 0.7)

  expect_true("tx_longitude" %in% names(odk_v7_split))
  expect_true("tx_latitude" %in% names(odk_v7_split))
  expect_true("tx_altitude" %in% names(odk_v7_split))

  expect_equal(odk_v7_split$tx_longitude, 128.40)
  expect_equal(odk_v7_split$tx_latitude, -14.80)
  expect_equal(odk_v7_split$tx_altitude, 10.9)
})

# nolint start
# This test worked while https://github.com/getodk/central-backend/issues/282
# was open.
#
# test_that("handle_ru_geotraces removes last empty coordinate from WKT", {
#   data("geo_fs") # parse T
#   data("geo_wkt") # parse T, wkt T
#
#   bad_coord <- "undefined NaN"
#   # Parsed, rectangled, WKT, geofields handled: geo_wkt
#
#   geo_fields <- geo_fs %>%
#     # dplyr::filter(type %in% c("geopoint", "geotrace", "geoshape")) %>%
#     dplyr::filter(type == "geotrace") %>%
#     magrittr::extract2("ruodk_name")
#
#   for (i in seq_len(length(geo_fields))) {
#
#     # WKT geofields must not contain bad_coord
#     testthat::expect_false(
#       stringr::str_detect(geo_wkt[[geo_fields[i]]], bad_coord),
#       label = glue::glue("WKT field {geo_fields[i]} contains \"{bad_coord}\"")
#     )
#   }
# })
# nolint end

# usethis::use_r("split_geotrace")  # nolint
