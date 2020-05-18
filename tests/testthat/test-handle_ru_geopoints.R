test_that(
  "handle_ru_geopoints annotates GeoJSON points with lon lat alt acc",
  {

  fs <- form_schema(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  # Parsed, rectangled, GeoJSON, geopoints handled
  d <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    wkt = FALSE
  )

  geo_fields <- fs %>%
    dplyr::filter(type  == "geopoint") %>%
    magrittr::extract2("ruodk_name")

  # This test requires a form with geo fields
  testthat::expect_true(
    length(geo_fields) > 0,
    label =
      glue::glue(
        "test-handle_ru_geopoints needs test data",
        "with at least one geo field. Form schema:\n\n",
        "{knitr::kable(fs)}"
      )
  )

  for (i in seq_len(length(geo_fields))){

    # GeoJSON should still exist  after handle_ru_geopoint as nested lists
    testthat::expect_true(
      is.list(d[[geo_fields[i]]]),
      label = glue::glue(
        "GeoJSON field {geo_fields[i]} should be a nested list"
      )
    )

    # handle_ru_geopoints should have appended new fields with postfixes
    # for lon, lat, alt, acc
    geofield_lon <- glue::glue("{geo_fields[i]}_longitude")
    geofield_lat <- glue::glue("{geo_fields[i]}_latitude")
    geofield_alt <- glue::glue("{geo_fields[i]}_altitude")
    geofield_acc <- glue::glue("{geo_fields[i]}_accuracy")
    testthat::expect_true(
      geofield_lon %in% names(d),
      label = glue::glue("handle_ru_geopoint appends {geofield_lon}")
    )
    testthat::expect_true(
      geofield_lat %in% names(d),
      label = glue::glue("handle_ru_geopoint appends {geofield_lat}")
    )
    testthat::expect_true(
      geofield_alt %in% names(d),
      label = glue::glue("handle_ru_geopoint appends {geofield_alt}")
    )
    testthat::expect_true(
      geofield_acc %in% names(d),
      label = glue::glue("handle_ru_geopoint appends {geofield_acc}")
    )
    # Fields must be numeric
    testthat::expect_true(
      is.numeric(d[,geofield_lon][[1]]),
      label = glue::glue("handle_ru_geopoint {geofield_lon} is numeric")
    )
    testthat::expect_true(
      is.numeric(d[,geofield_lat][[1]]),
      label = glue::glue("handle_ru_geopoint {geofield_lat} is numeric")
    )
    testthat::expect_true(
      is.numeric(d[,geofield_alt][[1]]),
      label = glue::glue("handle_ru_geopoint {geofield_alt} is numeric")
    )
    testthat::expect_true(
      is.numeric(d[,geofield_acc][[1]]),
      label = glue::glue("handle_ru_geopoint {geofield_acc} is numeric")
    )
  }

})

test_that(
  "handle_ru_geopoints annotates WKT points with lon lat alt (no acc)",
  {

  fs <- form_schema(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  # Parsed, rectangled, GeoJSON, geopoints handled
  d <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    wkt = TRUE
  )

  geo_fields <- fs %>%
    # dplyr::filter(type %in% c("geopoint", "geotrace", "geoshape")) %>%
    dplyr::filter(type  == "geopoint") %>%
    magrittr::extract2("ruodk_name")

  # This test requires a form with geo fields
  testthat::expect_true(
    length(geo_fields) > 0,
    label =
      glue::glue(
        "test-handle_ru_geopoints needs test data",
        "with at least one geopoint field. Form schema:\n\n{knitr::kable(fs)}"
      )
  )

  for (i in seq_len(length(geo_fields))){

    # GeoJSON should still exist after handle_ru_geopoint as nested lists
    testthat::expect_true(
      is.character(d[[geo_fields[i]]]),
      label = glue::glue("WKT field {geo_fields[i]} should be character")
    )

    # handle_ru_geopoints should have appended new fields with postfixes
    # for lon, lat, alt, acc if given
    geofield_lon <- glue::glue("{geo_fields[i]}_longitude")
    geofield_lat <- glue::glue("{geo_fields[i]}_latitude")
    geofield_alt <- glue::glue("{geo_fields[i]}_altitude")
    geofield_acc <- glue::glue("{geo_fields[i]}_accuracy")
    testthat::expect_true(
      geofield_lon %in% names(d),
      label = glue::glue("handle_ru_geopoint appends {geofield_lon}")
    )
    testthat::expect_true(
      geofield_lat %in% names(d),
      label = glue::glue("handle_ru_geopoint appends {geofield_lat}")
    )
    testthat::expect_true(
      geofield_alt %in% names(d),
      label = glue::glue("handle_ru_geopoint appends {geofield_alt}")
    )
    testthat::expect_false( # WKT has no accuracy
      geofield_acc %in% names(d),
      label = glue::glue("handle_ru_geopoint appends {geofield_acc}")
    )
  }

})
# usethis::use_r("handle_ru_geopoints")
