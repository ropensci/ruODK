test_that("handle_ru_geoshapes annotates GeoJSON lines with lon lat alt acc", {
  data("geo_fs") # parse T
  data("geo_gj_raw") # parse F, wkt F
  data("geo_gj") # parse T, wkt F
  data("geo_wkt_raw") # parse F, wkt T
  data("geo_wkt") # parse T, wkt T


  # Parsed, rectangled, GeoJSON, geofields handled: geo_gj

  geo_fields <- geo_fs %>%
    dplyr::filter(type == "geoshape") %>%
    magrittr::extract2("ruodk_name")

  for (i in seq_len(length(geo_fields))) {

    # GeoJSON should still exist  after handle_ru_geoshapes as nested lists
    testthat::expect_true(
      is.list(geo_gj[[geo_fields[i]]]),
      label = glue::glue(
        "GeoJSON field {geo_fields[i]} should be a nested list"
      )
    )

    # handle_ru_geoshapes should have appended new fields with postfixes
    # for lon, lat, alt, acc
    geofield_lon <- glue::glue("{geo_fields[i]}_longitude")
    geofield_lat <- glue::glue("{geo_fields[i]}_latitude")
    geofield_alt <- glue::glue("{geo_fields[i]}_altitude")
    geofield_acc <- glue::glue("{geo_fields[i]}_accuracy")
    testthat::expect_true(
      geofield_lon %in% names(geo_gj),
      label = glue::glue("handle_ru_geoshapes appends {geofield_lon}")
    )
    testthat::expect_true(
      geofield_lat %in% names(geo_gj),
      label = glue::glue("handle_ru_geoshapes appends {geofield_lat}")
    )
    testthat::expect_true(
      geofield_alt %in% names(geo_gj),
      label = glue::glue("handle_ru_geoshapes appends {geofield_alt}")
    )
    testthat::expect_false(
      geofield_acc %in% names(geo_gj),
      label = glue::glue("handle_ru_geoshapes appends {geofield_acc}")
    )
    # Fields must be numeric
    testthat::expect_true(
      is.numeric(geo_gj[, geofield_lon][[1]]),
      label = glue::glue("handle_ru_geoshapes {geofield_lon} is numeric")
    )
    testthat::expect_true(
      is.numeric(geo_gj[, geofield_lat][[1]]),
      label = glue::glue("handle_ru_geoshapes {geofield_lat} is numeric")
    )
    testthat::expect_true(
      is.numeric(geo_gj[, geofield_alt][[1]]),
      label = glue::glue("handle_ru_geoshapes {geofield_alt} is numeric")
    )
  }
})

test_that("handle_ru_geoshapes annotates WKT lines with lon lat alt (no acc)", {
  data("geo_fs") # parse T
  data("geo_gj_raw") # parse F, wkt F
  data("geo_gj") # parse T, wkt F
  data("geo_wkt_raw") # parse F, wkt T
  data("geo_wkt") # parse T, wkt T


  # Parsed, rectangled, WKT, geofields handled: geo_wkt

  geo_fields <- geo_fs %>%
    # dplyr::filter(type %in% c("geopoint", "geotrace", "geoshape")) %>%
    dplyr::filter(type == "geoshape") %>%
    magrittr::extract2("ruodk_name")

  for (i in seq_len(length(geo_fields))) {

    # GeoJSON should still exist after handle_ru_geoshapes as nested lists
    testthat::expect_true(
      is.character(geo_wkt[[geo_fields[i]]]),
      label = glue::glue("WKT field {geo_fields[i]} should be character")
    )

    # handle_ru_geoshapes should have appended new fields with postfixes
    # for lon, lat, alt, acc if given
    geofield_lon <- glue::glue("{geo_fields[i]}_longitude")
    geofield_lat <- glue::glue("{geo_fields[i]}_latitude")
    geofield_alt <- glue::glue("{geo_fields[i]}_altitude")
    geofield_acc <- glue::glue("{geo_fields[i]}_accuracy")
    testthat::expect_true(
      geofield_lon %in% names(geo_wkt),
      label = glue::glue("handle_ru_geoshapes appends {geofield_lon}")
    )
    testthat::expect_true(
      geofield_lat %in% names(geo_wkt),
      label = glue::glue("handle_ru_geoshapes appends {geofield_lat}")
    )
    testthat::expect_true(
      geofield_alt %in% names(geo_wkt),
      label = glue::glue("handle_ru_geoshapes appends {geofield_alt}")
    )
    testthat::expect_false(
      # WKT has no accuracy
      geofield_acc %in% names(geo_wkt),
      label = glue::glue("handle_ru_geoshapes appends {geofield_acc}")
    )
    # Fields must be numeric
    testthat::expect_true(
      is.numeric(geo_wkt[, geofield_lon][[1]]),
      label = glue::glue("handle_ru_geoshapes {geofield_lon} is numeric")
    )
    testthat::expect_true(
      is.numeric(geo_wkt[, geofield_lat][[1]]),
      label = glue::glue("handle_ru_geoshapes {geofield_lat} is numeric")
    )
    testthat::expect_true(
      is.numeric(geo_wkt[, geofield_alt][[1]]),
      label = glue::glue("handle_ru_geoshapes {geofield_alt} is numeric")
    )
  }
})

# Fixed upstream with https://github.com/getodk/central-backend/issues/282
# test_that("handle_ru_geoshapes removes last empty coordinate from WKT", {
#   data("geo_fs") # parse T
#   data("geo_wkt") # parse T, wkt T
#
#   bad_coord <- "undefined NaN"
#   # Parsed, rectangled, WKT, geofields handled: geo_wkt
#
#   geo_fields <- geo_fs %>%
#     # dplyr::filter(type %in% c("geopoint", "geotrace", "geoshape")) %>%
#     dplyr::filter(type == "geoshape") %>%
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

# test_that("handle_ru_geoshapes removes last empty coordinate from GJ", {
#   data("geo_fs") # parse T
#   data("geo_gj") # parse T, wkt T
#
#
#   geo_fields <- geo_fs %>%
#     # dplyr::filter(type %in% c("geopoint", "geotrace", "geoshape")) %>%
#     dplyr::filter(type == "geoshape") %>%
#     magrittr::extract2("ruodk_name")
#
#   for (i in seq_len(length(geo_fields))) {
#     len_coords <- length(geo_gj[[geo_fields[i]]][[1]]$coordinates)
#
#     # Cmpty coord is list(NULL, NULL) which compacts to list() of length 0
#     last_coord_compact <- purrr::compact(
#       geo_gj[[geo_fields[i]]][[1]]$coordinates[[len_coords]]
#     )
#     # WKT geofields must not contain bad_coord
#     testthat::expect_false(
#       length(last_coord_compact) == 0,
#       label = glue::glue("GJ field {geo_fields[i]} last coord is not empty")
#     )
#   }
# })

# usethis::use_r("handle_ru_geoshapes") # nolint
