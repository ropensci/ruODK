context("test-odata_submission_rectangle.R")

test_that("odata_submission_rectangle works", {
  data_parsed <- odata_submission_rectangle(fq_raw, verbose = TRUE)

  # Field "device_id" is known part of fq_raw
  testthat::expect_equal(
    data_parsed$device_id[[1]],
    fq_raw$value[[1]]$device_id
  )

  # fq_raw has two submissions
  testthat::expect_equal(length(fq_raw$value), nrow(data_parsed))
})


test_that("odata_submission_rectangle parses GeoJSON to nested list", {
  data("geo_fs") # parse T
  data("geo_gj_raw") # parse F, wkt F
  # data("geo_gj")      # parse T, wkt F
  # data("geo_wkt_raw") # parse F, wkt T
  # data("geo_wkt")     # parse T, wkt T

  # Unparsed, rectangled, GeoJSON
  d <- geo_gj_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)

  geo_fields <- geo_fs %>%
    dplyr::filter(type %in% c("geopoint", "geotrace", "geoshape")) %>%
    magrittr::extract2("ruodk_name")

  # This test requires a form with geo fields
  testthat::expect_true(
    length(geo_fields) > 0,
    label =
      glue::glue(
        "test-handle_ru_geopoints needs test data",
        "with at least one geo field. Form schema:\n\n",
        "{knitr::kable(geo_fs)}"
      )
  )

  # GeoJSON should be nested lists
  for (i in seq_len(length(geo_fields))) {
    testthat::expect_true(
      is.list(d[[geo_fields[i]]]),
      label = glue::glue(
        "GeoJSON field {geo_fields[i]} should be a nested list"
      )
    )
  }
})

test_that("odata_submission_rectangle parses WKT as text", {
  data("geo_fs") # parse T
  # data("geo_gj_raw")  # parse F, wkt F
  # data("geo_gj")      # parse T, wkt F
  data("geo_wkt_raw") # parse F, wkt T
  # data("geo_wkt")     # parse T, wkt T

  # Unparsed, rectangled, GeoJSON
  d <- geo_wkt_raw %>%
    odata_submission_rectangle(form_schema = geo_fs)

  geo_fields <- geo_fs %>%
    dplyr::filter(type %in% c("geopoint", "geotrace", "geoshape")) %>%
    magrittr::extract2("ruodk_name")

  # This test requires a form with geo fields
  testthat::expect_true(
    length(geo_fields) > 0,
    label = glue::glue(
      "test-handle_ru_geopoints needs test data",
      "with at least one geo field. Form schema:\n\n",
      "{knitr::kable(geo_fs)}"
    )
  )

  # WKT should be character strings
  for (i in seq_len(length(geo_fields))) {
    testthat::expect_true(
      is.character(d[[geo_fields[i]]]),
      label = glue::glue("WKT field {geo_fields[i]} should be character")
    )
  }
})

# Tests code
# usethis::use_r("odata_submission_rectangle")
