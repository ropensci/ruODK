test_that("submission_get works", {
  vcr::use_cassette("test_submission_get0", {
    sl <- submission_list(
      pid = get_test_pid(),
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })

  vcr::use_cassette("test_submission_get1", {
    sub <- get_one_submission(
      sl$instance_id[[1]],
      pid = get_test_pid(),
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })

  vcr::use_cassette("test_submission_get2", {
    subs <- submission_get(
      sl$instance_id,
      pid = get_test_pid(),
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })

  testthat::expect_equal(class(sub), "list")
  testthat::expect_equal(class(subs), "list")


  # The details for one submission return exactly one row
  testthat::expect_equal(length(sub), 13)
  testthat::expect_equal(length(subs), 1) # number of submissions

  # The columns are form fields or groups,
  # plus the submission data in column 'xml`
  # names(sub) # nolint
  cn <- c(
    "meta",
    "encounter_start_datetime",
    "reporter",
    "device_id",
    "location",
    "habitat",
    "vegetation_stratum",
    "vegetation_stratum",
    "vegetation_stratum",
    "perimeter",
    "taxon_encounter",
    "taxon_encounter",
    "encounter_end_datetime"
  )
  testthat::expect_equal(names(sub), cn)
  testthat::expect_true("encounter_start_datetime" %in% names(sub))
  testthat::expect_true("habitat" %in% names(sub))
  testthat::expect_true("vegetation_stratum" %in% names(sub))
  testthat::expect_true("taxon_encounter" %in% names(sub))
  testthat::expect_true("encounter_end_datetime" %in% names(sub))
})

# usethis::edit_file("R/submission_get.R") # nolint
