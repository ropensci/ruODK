test_that("predict_ruodk_name works", {
  testthat::expect_equal(
    predict_ruodk_name("bar", "Submissions.foo"),
    "foo_bar"
  )

  testthat::expect_equal(
    predict_ruodk_name("bar", "Submissions"),
    "bar"
  )

  testthat::expect_equal(
    predict_ruodk_name("rock", "Submissions.foo_fighters"),
    "foo_fighters_rock"
  )
})

test_that("form_schema works with ODK Central v0.8", {
  vcr::use_cassette("test_fid_form_schema", {
  fs <- form_schema(
    flatten = FALSE,
    parse = FALSE,
    odata = FALSE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    verbose = TRUE
  )})

  testthat::expect_true(tibble::is_tibble(fs))
  testthat::expect_equal(
    names(fs),
    c("path", "name", "type", "binary", "ruodk_name")
  )
  testthat::expect_true("encounter_start_datetime" %in% fs$name)
  testthat::expect_true("quadrat_photo" %in% fs$name)

  # nolint start
  # # Attachments
  # fsp %>% dplyr::filter(type=="binary")
  #
  # # dateYime
  # fsp %>% dplyr::filter(type=="dateTime")
  #
  # # Point location
  # fsp %>% dplyr::filter(type=="geopoint")
  # nolint end
})

test_that("form_schema_parse debug messages work", {
  data("fs_v7_raw")
  data("fs_v7")

  testthat::capture_output(
    testthat::expect_message(
      fs_v7_parsed <- form_schema_parse(fs_v7_raw, verbose = TRUE)
    )
  )

  testthat::expect_equal(class(fs_v7_parsed), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true("observation_start_time" %in% fs_v7_parsed$name)
  testthat::expect_true("disturbance_cause" %in% fs_v7_parsed$name)

  testthat::expect_equal(fs_v7, fs_v7_parsed)
})
