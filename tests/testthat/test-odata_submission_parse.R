context("test-odata_submission_rectangle.R")

test_that("odata_submission_rectangle works with gaps in first submission", {
  t <- tempdir()
  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_gap(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = FALSE,
    verbose = TRUE
  )

  fresh_raw_parsed <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_gap(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    verbose = TRUE,
    local_dir = t
  )

  fresh_parsed <- fresh_raw %>% odata_submission_rectangle(verbose = TRUE)
  testthat::expect_gte(nrow(fresh_parsed), length(fresh_raw$value))
  testthat::expect_gte(nrow(fresh_parsed), nrow(fresh_raw_parsed))

  testthat::expect_equal(
    class(fresh_raw_parsed$encounter_start_datetime[1]),
    c("POSIXct", "POSIXt")
  )
})

# nolint start
# usethis::use_r("odata_submission_get")
# usethis::use_r("odata_submission_rectangle")
# nolint end
