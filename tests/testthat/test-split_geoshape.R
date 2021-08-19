test_that("split_geoshape works with GeoJSON", {
  data("geo_fs")
  data("geo_gj_raw")

  # Find variable names of geoshapes
  geo_fields <- geo_fs %>%
    dplyr::filter(type == "geoshape") %>%
    magrittr::extract2("ruodk_name")

  # Rectangle but don't parse submission data (GeoJSON and WKT)
  geo_gj_rt <- geo_gj_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)

  # GeoJSON data with first geoshape split
  gj_first_gs <- split_geoshape(
    geo_gj_rt,
    geo_fields[1],
    wkt = FALSE,
    odkc_version = get_test_odkc_version()
  )

  expect_true(
    geo_fields[1] %in% names(gj_first_gs),
    label = "split_geoshape retains original GeoJSON field"
  )

  geofield_lon_gs <- glue::glue("{geo_fields[1]}_longitude")
  geofield_lat_gs <- glue::glue("{geo_fields[1]}_latitude")
  geofield_alt_gs <- glue::glue("{geo_fields[1]}_altitude")

  expect_true(
    geofield_lon_gs %in% names(gj_first_gs),
    label = "split_geoshape extracts GeoJSON longitude"
  )
  expect_true(
    geofield_lat_gs %in% names(gj_first_gs),
    label = "split_geoshape extracts GeoJSON latitude"
  )
  expect_true(
    geofield_alt_gs %in% names(gj_first_gs),
    label = "split_geoshape extracts GeoJSON altitude"
  )

  # TODO FIXME
  # https://github.com/ropensci/ruODK/issues/131
  expect_true(
    gj_first_gs %>% magrittr::extract2(geofield_lon_gs) %>% is.numeric(),
    label = "split_geoshape casts extracted GeoJSON longitude to numeric"
  )
  expect_true(
    gj_first_gs %>% magrittr::extract2(geofield_lat_gs) %>% is.numeric(),
    label = "split_geoshape casts extracted GeoJSON latitude to numeric"
  )
  expect_true(
    gj_first_gs %>% magrittr::extract2(geofield_alt_gs) %>% is.numeric(),
    label = "split_geoshape casts extracted GeoJSON altitude to numeric"
  )
})

test_that("split_geoshape works with WKT", {
  data("geo_fs")
  data("geo_wkt_raw")

  # Find variable names of geoshapes
  geo_fields <- geo_fs %>%
    dplyr::filter(type == "geoshape") %>%
    magrittr::extract2("ruodk_name")

  # Rectangle but don't parse submission data (GeoJSON and WKT)
  geo_wkt_rt <- geo_wkt_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)

  # GeoJSON data with first geoshape split
  wkt_first_gt <- split_geoshape(
    geo_wkt_rt,
    geo_fields[1],
    wkt = TRUE,
    odkc_version = get_test_odkc_version()
  )

  expect_true(
    geo_fields[1] %in% names(wkt_first_gt),
    label = "split_geoshape retains original WKT field"
  )

  geofield_lon <- glue::glue("{geo_fields[1]}_longitude")
  geofield_lat <- glue::glue("{geo_fields[1]}_latitude")
  geofield_alt <- glue::glue("{geo_fields[1]}_altitude")

  expect_true(
    geofield_lon %in% names(wkt_first_gt),
    label = "split_geoshape extracts WKT longitude"
  )
  expect_true(
    geofield_lat %in% names(wkt_first_gt),
    label = "split_geoshape extracts WKT latitude"
  )
  expect_true(
    geofield_alt %in% names(wkt_first_gt),
    label = "split_geoshape extracts WKT altitude"
  )

  expect_true(
    wkt_first_gt %>% magrittr::extract2(geofield_lon) %>% is.numeric(),
    label = "split_geoshape casts extracted WKT longitude to numeric"
  )
  expect_true(
    wkt_first_gt %>% magrittr::extract2(geofield_lat) %>% is.numeric(),
    label = "split_geoshape casts extracted WKT latitude to numeric"
  )
  expect_true(
    wkt_first_gt %>% magrittr::extract2(geofield_alt) %>% is.numeric(),
    label = "split_geoshape casts extracted WKT altitude to numeric"
  )
})

test_that("split_geoshape works with no data", {
  odk_empty <- tibble::tibble()
  odk_split <- split_geoshape(odk_empty, "tx")
  expect_s3_class(odk_split, class = c("tbl_df", "tbl", "data.frame"))
})

test_that("split_geoshape works with ODK Linestrings", {

  # ODK Central v0.7 and lower ignore the WKT argument for geotrace and geoshape
  # nolint start
  # ruODK::odata_submission_get(wkt = TRUE, parse = TRUE)
  # ruODK::odata_submission_get(wkt = FALSE, parse = FALSE) %>%
  # ruODK::odata_submission_rectangle()
  # First three points shown with truncated decimal places
  # nolint end
  odk_v7 <- tibble::tibble(
    id = 1,
    tx = paste0(
      "-14.80 128.40 10.9 5.9;-14.81 128.41 1.7 1.9;",
      "-14.82 128.42 1.9 1.7;-14.80 128.40 10.9 5.9;"
    )
  )
  odk_v7_split <- split_geoshape(odk_v7, "tx", odkc_version = 0.7)

  expect_true("tx_longitude" %in% names(odk_v7_split))
  expect_true("tx_latitude" %in% names(odk_v7_split))
  expect_true("tx_altitude" %in% names(odk_v7_split))

  expect_equal(odk_v7_split$tx_longitude, 128.40)
  expect_equal(odk_v7_split$tx_latitude, -14.80)
  expect_equal(odk_v7_split$tx_altitude, 10.9)
})


# usethis::use_r("split_geoshape") # nolint
