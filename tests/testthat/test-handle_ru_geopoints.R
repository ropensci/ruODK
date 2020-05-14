test_that("handle_ru_geopoints produces coordinates", {
  library(magrittr)
  data("fq_raw")
  data("fq_form_schema")

  fq_with_geo <- fq_raw %>%
    ruODK::odata_submission_rectangle() %>%
    ruODK::handle_ru_geopoints(form_schema = fq_form_schema)

  geopoint_fields <- fq_form_schema %>%
    dplyr::filter(type == "geopoint") %>%
    magrittr::extract2("ruodk_name")

  if (length(geopoint_fields) == 0) {
    rlang::warn(
      glue::glue(
        "test-handle_ru_geopoints needs test data",
        "with at least one geopoint field. Form schema:\n\n",
        "{knitr::kable(fq_form_schema)}"
      )
    )
  }

  # Geopoint fields have been split into separate coordinate components
  testthat::expect_false(geopoint_fields[[1]] %in% names(fq_with_geo))
})

test_that("handle_ru_geopoints does all the things", {

  svc <- odata_service_get(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  fs <- form_schema(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )


  d_gj <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    wkt = FALSE,
    table = svc$name[1]
  )
  # GeoJSON remains a list column
  testthat::expect_equal(class(d_gj$point_location_point_gps), "list")
  testthat::expect_equal(class(d_gj$path_location_path_gps), "list")
  testthat::expect_equal(class(d_gj$shape_location_shape_gps), "list")


  d <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    wkt = TRUE,
    table = svc$name[1]
  )

  # names(d)

  geopoint_fields <- fs %>%
    dplyr::filter(type == "geopoint") %>%
    magrittr::extract2("ruodk_name")

  # Geopoints will have been split into
  # <fieldname>_{latitude, longitude, altitude}
  testthat::expect_false(geopoint_fields[[1]] %in% names(d))

  # LINESTRING (115.88501214981079 -31.997176185855277 0, ..,)
  testthat::expect_true("path_location_path_gps" %in% names(d))
  testthat::expect_true("path_location_path_map" %in% names(d))
  testthat::expect_true("path_location_path_manual" %in% names(d))

  # "POLYGON ((115.88551204651594 -31.998645069556574 0,
  testthat::expect_true("shape_location_shape_gps" %in% names(d))
  testthat::expect_true("shape_location_shape_map" %in% names(d))
  testthat::expect_true("shape_location_shape_manual" %in% names(d))

  # data raw, unparsed
  dr <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_wkt(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = FALSE,
    wkt = TRUE,
    table = svc$name[1]
  ) %>%
    odata_submission_rectangle(form_schema = fs)

  # WKT remains a string
  testthat::expect_equal(class(dr$point_location_point_gps), "character")
  testthat::expect_equal(class(dr$path_location_path_gps), "character")
  testthat::expect_equal(class(dr$shape_location_shape_gps), "character")

})

# usethis::use_r("handle_ru_geopoints")
