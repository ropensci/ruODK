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
  )

  testthat::expect_equal(class(fs), "data.frame")
  testthat::expect_equal(names(fs), c("path", "name", "type", "ruodk_name"))
  testthat::expect_true("encounter_start_datetime" %in% fs$name)
  testthat::expect_true("quadrat_photo" %in% fs$name)

  # # Attachments
  # fsp %>% dplyr::filter(type=="binary")
  #
  # # dateYime
  # fsp %>% dplyr::filter(type=="dateTime")
  #
  # # Point location
  # fsp %>% dplyr::filter(type=="geopoint")
})

# TODO run this test against ODK Central v0.7
# test_that("form_schema_parse debug messages work", {
#   fs <- form_schema(
#     flatten = FALSE,
#     parse = FALSE,
#     pid = get_test_pid(),
#     fid = get_test_fid(),
#     url = get_test_url(),
#     un = get_test_un(),
#     pw = get_test_pw(),
#     odkc_version = 0.8
#   )
#
#   testthat::capture_output(
#     testthat::expect_message(
#       fsp <- form_schema_parse(fs, verbose = TRUE)
#     )
#   )
#
#   testthat::expect_equal(class(fsp), c("tbl_df", "tbl", "data.frame"))
#   testthat::expect_true("encounter_start_datetime" %in% fsp$name)
#   testthat::expect_true("quadrat_photo" %in% fsp$name)
# })
