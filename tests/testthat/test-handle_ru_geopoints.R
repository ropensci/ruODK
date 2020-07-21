test_that(
  "handle_ru_geopoints annotates GeoJSON points with lon lat alt acc",
  { # nolint
    # nolint start
    data("geo_fs") # parse T
    # data("geo_gj_raw")  # parse F, wkt F
    data("geo_gj") # parse T, wkt F
    # data("geo_wkt_raw") # parse F, wkt T
    # data("geo_wkt")     # parse T, wkt T
    # nolint end

    # Parsed, rectangled, GeoJSON, geopoints handled: geo_gj
    geo_fields <- geo_fs %>%
      dplyr::filter(type == "geopoint") %>%
      magrittr::extract2("ruodk_name")


    for (i in seq_len(length(geo_fields))) {
      # GeoJSON should still exist  after handle_ru_geopoint as nested lists
      testthat::expect_true(
        is.list(geo_gj[[geo_fields[i]]]),
        label = glue::glue(
          "GeoJSON field {geo_fields[i]} should be a nested list"
        )
      )

      # handle_ru_geopoints should have appended new fields with postfixes
      # for lon, lat, alt, acc
      geofield_lon <-
        glue::glue("{geo_fields[i]}_longitude")
      geofield_lat <- glue::glue("{geo_fields[i]}_latitude")
      geofield_alt <- glue::glue("{geo_fields[i]}_altitude")
      geofield_acc <- glue::glue("{geo_fields[i]}_accuracy")
      testthat::expect_true(
        geofield_lon %in% names(geo_gj),
        label = glue::glue("handle_ru_geopoint appends {geofield_lon}")
      )
      testthat::expect_true(
        geofield_lat %in% names(geo_gj),
        label = glue::glue("handle_ru_geopoint appends {geofield_lat}")
      )
      testthat::expect_true(
        geofield_alt %in% names(geo_gj),
        label = glue::glue("handle_ru_geopoint appends {geofield_alt}")
      )
      testthat::expect_true(
        geofield_acc %in% names(geo_gj),
        label = glue::glue("handle_ru_geopoint appends {geofield_acc}")
      )
      # Fields must be numeric
      testthat::expect_true(
        is.numeric(geo_gj[, geofield_lon][[1]]),
        label = glue::glue("handle_ru_geopoint {geofield_lon} is numeric")
      )
      testthat::expect_true(
        is.numeric(geo_gj[, geofield_lat][[1]]),
        label = glue::glue("handle_ru_geopoint {geofield_lat} is numeric")
      )
      testthat::expect_true(
        is.numeric(geo_gj[, geofield_alt][[1]]),
        label = glue::glue("handle_ru_geopoint {geofield_alt} is numeric")
      )
      testthat::expect_true(
        is.numeric(geo_gj[, geofield_acc][[1]]),
        label = glue::glue("handle_ru_geopoint {geofield_acc} is numeric")
      )
    }
  }
)

test_that(
  "handle_ru_geopoints annotates WKT points with lon lat alt (no acc)",
  { # nolint
    data("geo_fs") # parse T
    data("geo_wkt") # parse T, wkt T

    # Parsed, rectangled, WKT, geopoints handled: geo_wkt

    geo_fields <- geo_fs %>%
      dplyr::filter(type == "geopoint") %>%
      magrittr::extract2("ruodk_name")

    for (i in seq_len(length(geo_fields))) {
      # GeoJSON should still exist after handle_ru_geopoint as nested lists
      testthat::expect_true(
        is.character(geo_wkt[[geo_fields[i]]]),
        label = glue::glue("WKT field {geo_fields[i]} should be character")
      )

      # handle_ru_geopoints should have appended new fields with postfixes
      # for lon, lat, alt, acc if given
      geofield_lon <-
        glue::glue("{geo_fields[i]}_longitude")
      geofield_lat <- glue::glue("{geo_fields[i]}_latitude")
      geofield_alt <- glue::glue("{geo_fields[i]}_altitude")
      geofield_acc <- glue::glue("{geo_fields[i]}_accuracy")
      testthat::expect_true(
        geofield_lon %in% names(geo_wkt),
        label = glue::glue("handle_ru_geopoint appends {geofield_lon}")
      )
      testthat::expect_true(
        geofield_lat %in% names(geo_wkt),
        label = glue::glue("handle_ru_geopoint appends {geofield_lat}")
      )
      testthat::expect_true(
        geofield_alt %in% names(geo_wkt),
        label = glue::glue("handle_ru_geopoint appends {geofield_alt}")
      )
      testthat::expect_false(
        # WKT has no accuracy
        geofield_acc %in% names(geo_wkt),
        label = glue::glue("handle_ru_geopoint appends {geofield_acc}")
      )
    }
  }
)

test_that("handle_ru_* parses geotypes", {
  testthat::skip_if(
    get_test_fid_wkt() == "",
    message = "This test requires env var TEST_FID_WKT, see CONTRIBUTING.md"
  )

  data("geo_fs") # parse T
  data("geo_gj_raw") # parse F, wkt F
  data("geo_gj") # parse T, wkt F
  data("geo_wkt_raw") # parse F, wkt T
  data("geo_wkt") # parse T, wkt T

  geo_gj_raw_fresh <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = FALSE,
    wkt = FALSE
  )
  geo_gj_fresh <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    wkt = FALSE
  )
  geo_wkt_raw_fresh <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = FALSE,
    wkt = TRUE
  )
  geo_wkt_fresh <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    wkt = TRUE
  )

  testthat::expect_equal(geo_gj_raw, geo_gj_raw_fresh)
  testthat::expect_equal(geo_gj, geo_gj_fresh)
  testthat::expect_equal(
    geo_wkt_raw$value[[1]]$meta$instanceID,
    geo_wkt_raw_fresh$value[[1]]$meta$instanceID
  )
  testthat::expect_equal(geo_wkt[1, ]$id, geo_wkt_fresh[1, ]$id)
})

# usethis::use_r("handle_ru_geopoints") # nolint
