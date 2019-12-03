context("test-odata_submission_parse.R")

test_that("odata_submission_get works with one known dataset", {
  t <- tempdir()
  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid_gap(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    parse = FALSE
  )

  testthat::expect_error(
    fresh_raw_parsed <- odata_submission_get(
      pid = get_test_pid(),
      fid = get_test_fid_gap(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      parse = TRUE,
      verbose = TRUE,
      local_dir = t
    )

    # Throws error:
    # test-odata_submission_parse.R:13: error: odata_submission_get works with one known dataset
    # Can't cast `track_photos$...1` <logical> to `track_photos$...1` <vctrs_unspecified>.
  )

  # fresh_parsed <- fresh_raw %>% odata_submission_parse()
  # testthat::expect_gte(nrow(fresh_parsed), length(fresh_raw$value))
  # testthat::expect_gte(nrow(fresh_parsed), nrow(fresh_raw_parsed))

  # testthat::expect_equal(
  #   class(fresh_raw_parsed$encounter_start_datetime),
  #   c("POSIXct", "POSIXt")
  # )

  # local_files <- fresh_raw_parsed %>%
  #   dplyr::filter(!is.null(quadrat_photo)) %>%
  #   magrittr::extract2("quadrat_photo") %>%
  #   as.character()
  # purrr::map(local_files, ~ testthat::expect_true(fs::file_exists(.)))
})
