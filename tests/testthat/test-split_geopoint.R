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

test_that("split_geopoint works with GeoJSON", {
  library(magrittr)
  data("geo_fs")
  data("geo_gj_raw")

  # Find variable names of geopoints
  geo_fields <- geo_fs %>%
    dplyr::filter(type == "geopoint") %>%
    magrittr::extract2("ruodk_name")

  # Rectangle but don't parse submission data (GeoJSON and WKT)
  geo_gj_rt <- geo_gj_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)

  # GeoJSON data with first geotrace split
  gj_first_gt <- split_geopoint(geo_gj_rt, geo_fields[1], wkt = FALSE)

  expect_true(
    geo_fields[1] %in% names(gj_first_gt),
    label = "split_geopoint retains original GeoJSON field"
  )

  geofield_lon <- glue::glue("{geo_fields[1]}_longitude")
  geofield_lat <- glue::glue("{geo_fields[1]}_latitude")
  geofield_alt <- glue::glue("{geo_fields[1]}_altitude")

  expect_true(
    geofield_lon %in% names(gj_first_gt),
    label = "split_geopoint extracts GeoJSON longitude"
  )
  expect_true(
    geofield_lat %in% names(gj_first_gt),
    label = "split_geopoint extracts GeoJSON latitude"
  )
  expect_true(
    geofield_alt %in% names(gj_first_gt),
    label = "split_geopoint extracts GeoJSON altitude"
  )

  expect_true(
    gj_first_gt %>% magrittr::extract2(geofield_lon) %>% is.numeric(),
    label = "split_geopoint casts extracted GeoJSON longitude to numeric"
  )
  expect_true(
    gj_first_gt %>% magrittr::extract2(geofield_lat) %>% is.numeric(),
    label = "split_geopoint casts extracted GeoJSON latitude to numeric"
  )
  expect_true(
    gj_first_gt %>% magrittr::extract2(geofield_alt) %>% is.numeric(),
    label = "split_geopoint casts extracted GeoJSON altitude to numeric"
  )
})

test_that("split_geopoint works with WKT", {
  library(magrittr)
  data("geo_fs")
  data("geo_wkt_raw")

  # Find variable names of geopoints
  geo_fields <- geo_fs %>%
    dplyr::filter(type == "geopoint") %>%
    magrittr::extract2("ruodk_name")

  # Rectangle but don't parse submission data (GeoJSON and WKT)
  geo_wkt_rt <- geo_wkt_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)

  # GeoJSON data with first geopoint split
  wkt_first_gt <- split_geopoint(geo_wkt_rt, geo_fields[1], wkt = TRUE)

  expect_true(
    geo_fields[1] %in% names(wkt_first_gt),
    label = "split_geopoint retains original WKT field"
  )

  geofield_lon <- glue::glue("{geo_fields[1]}_longitude")
  geofield_lat <- glue::glue("{geo_fields[1]}_latitude")
  geofield_alt <- glue::glue("{geo_fields[1]}_altitude")

  expect_true(
    geofield_lon %in% names(wkt_first_gt),
    label = "split_geopoint extracts WKT longitude"
  )
  expect_true(
    geofield_lat %in% names(wkt_first_gt),
    label = "split_geopoint extracts WKT latitude"
  )
  expect_true(
    geofield_alt %in% names(wkt_first_gt),
    label = "split_geopoint extracts WKT altitude"
  )

  expect_true(
    wkt_first_gt %>% magrittr::extract2(geofield_lon) %>% is.numeric(),
    label = "split_geopoint casts extracted WKT longitude to numeric"
  )
  expect_true(
    wkt_first_gt %>% magrittr::extract2(geofield_lat) %>% is.numeric(),
    label = "split_geopoint casts extracted WKT latitude to numeric"
  )
  expect_true(
    wkt_first_gt %>% magrittr::extract2(geofield_alt) %>% is.numeric(),
    label = "split_geopoint casts extracted WKT altitude to numeric"
  )
})

# usethis::use_r("split_geopoint")
