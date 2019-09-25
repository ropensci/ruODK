test_that("form_schema_parse works", {
  fs <- form_schema(
    flatten = FALSE,
    parse = FALSE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  fsp <- form_schema_parse(fs)

  testthat::expect_equal(class(fsp), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_equal(names(fsp), c("type", "name", "path"))
  testthat::expect_true("encounter_start_datetime" %in% fsp$name)
  testthat::expect_true("quadrat_photo" %in% fsp$name)

  # # Attachments
  # fsp %>% dplyr::filter(type=="binary")
  #
  # # dateYime
  # fsp %>% dplyr::filter(type=="dateTime")
  #
  # # Point location
  # fsp %>% dplyr::filter(type=="geopoint")
})

test_that("form_schema_parse debug messages work", {
  fs <- form_schema(
    flatten = FALSE,
    parse = FALSE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  testthat::capture_output(
    testthat::expect_message(
      fsp <- form_schema_parse(fs, verbose = TRUE)
    )
  )

  testthat::expect_equal(class(fsp), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true("encounter_start_datetime" %in% fsp$name)
  testthat::expect_true("quadrat_photo" %in% fsp$name)
})
