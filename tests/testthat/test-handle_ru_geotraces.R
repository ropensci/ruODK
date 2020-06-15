test_that("handle_ru_geotraces annotates GeoJSON lines with lon lat alt acc", {
  data("geo_fs") # parse T
  data("geo_gj_raw") # parse F, wkt F
  data("geo_gj") # parse T, wkt F
  data("geo_wkt_raw") # parse F, wkt T
  data("geo_wkt") # parse T, wkt T


  # Parsed, rectangled, GeoJSON, geofields handled: geo_gj

  geo_fields <- geo_fs %>%
    dplyr::filter(type == "geotrace") %>%
    magrittr::extract2("ruodk_name")

  for (i in seq_len(length(geo_fields))) {

    # GeoJSON should still exist  after handle_ru_geotraces as nested lists
    testthat::expect_true(
      is.list(geo_gj[[geo_fields[i]]]),
      label = glue::glue(
        "GeoJSON field {geo_fields[i]} should be a nested list"
      )
    )

    # handle_ru_geotraces should have appended new fields with postfixes
    # for lon, lat, alt, acc
    geofield_lon <- glue::glue("{geo_fields[i]}_longitude")
    geofield_lat <- glue::glue("{geo_fields[i]}_latitude")
    geofield_alt <- glue::glue("{geo_fields[i]}_altitude")
    geofield_acc <- glue::glue("{geo_fields[i]}_accuracy")
    testthat::expect_true(
      geofield_lon %in% names(geo_gj),
      label = glue::glue("handle_ru_geotraces appends {geofield_lon}")
    )
    testthat::expect_true(
      geofield_lat %in% names(geo_gj),
      label = glue::glue("handle_ru_geotraces appends {geofield_lat}")
    )
    testthat::expect_true(
      geofield_alt %in% names(geo_gj),
      label = glue::glue("handle_ru_geotraces appends {geofield_alt}")
    )
    testthat::expect_false(
      geofield_acc %in% names(geo_gj),
      label = glue::glue("handle_ru_geotraces appends {geofield_acc}")
    )
    # Fields must be numeric
    testthat::expect_true(
      is.numeric(geo_gj[, geofield_lon][[1]]),
      label = glue::glue("handle_ru_geotraces {geofield_lon} is numeric")
    )
    testthat::expect_true(
      is.numeric(geo_gj[, geofield_lat][[1]]),
      label = glue::glue("handle_ru_geotraces {geofield_lat} is numeric")
    )
    testthat::expect_true(
      is.numeric(geo_gj[, geofield_alt][[1]]),
      label = glue::glue("handle_ru_geotraces {geofield_alt} is numeric")
    )
  }
})

test_that("handle_ru_geotraces annotates WKT lines with lon lat alt (no acc)", {
  data("geo_fs") # parse T
  data("geo_gj_raw") # parse F, wkt F
  data("geo_gj") # parse T, wkt F
  data("geo_wkt_raw") # parse F, wkt T
  data("geo_wkt") # parse T, wkt T


  # Parsed, rectangled, WKT, geofields handled: geo_wkt

  geo_fields <- geo_fs %>%
    # dplyr::filter(type %in% c("geopoint", "geotrace", "geoshape")) %>%
    dplyr::filter(type == "geotrace") %>%
    magrittr::extract2("ruodk_name")

  for (i in seq_len(length(geo_fields))) {

    # GeoJSON should still exist after handle_ru_geotraces as nested lists
    testthat::expect_true(
      is.character(geo_wkt[[geo_fields[i]]]),
      label = glue::glue("WKT field {geo_fields[i]} should be character")
    )

    # handle_ru_geotraces should have appended new fields with postfixes
    # for lon, lat, alt, acc if given
    geofield_lon <- glue::glue("{geo_fields[i]}_longitude")
    geofield_lat <- glue::glue("{geo_fields[i]}_latitude")
    geofield_alt <- glue::glue("{geo_fields[i]}_altitude")
    geofield_acc <- glue::glue("{geo_fields[i]}_accuracy")
    testthat::expect_true(
      geofield_lon %in% names(geo_wkt),
      label = glue::glue("handle_ru_geotraces appends {geofield_lon}")
    )
    testthat::expect_true(
      geofield_lat %in% names(geo_wkt),
      label = glue::glue("handle_ru_geotraces appends {geofield_lat}")
    )
    testthat::expect_true(
      geofield_alt %in% names(geo_wkt),
      label = glue::glue("handle_ru_geotraces appends {geofield_alt}")
    )
    testthat::expect_false( # WKT has no accuracy
      geofield_acc %in% names(geo_wkt),
      label = glue::glue("handle_ru_geotraces appends {geofield_acc}")
    )
    # Fields must be numeric
    testthat::expect_true(
      is.numeric(geo_wkt[, geofield_lon][[1]]),
      label = glue::glue("handle_ru_geotraces {geofield_lon} is numeric")
    )
    testthat::expect_true(
      is.numeric(geo_wkt[, geofield_lat][[1]]),
      label = glue::glue("handle_ru_geotraces {geofield_lat} is numeric")
    )
    testthat::expect_true(
      is.numeric(geo_wkt[, geofield_alt][[1]]),
      label = glue::glue("handle_ru_geotraces {geofield_alt} is numeric")
    )
  }
})

# usethis::use_r("handle_ru_geotraces")
