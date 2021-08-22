test_that("submission_detail works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "", message = "Test server not configured")

  vcr::use_cassette("test_submission_detail0", {
    sl <- submission_list(
      pid = get_test_pid(),
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )

    sub <- submission_detail(
      sl$instance_id[[1]],
      pid = get_test_pid(),
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })

  # submission_detail returns a tibble
  testthat::expect_equal(class(sub), c("tbl_df", "tbl", "data.frame"))


  # The details for one submission return exactly one row
  testthat::expect_equal(nrow(sub), 1)

  # The columns are metadata, plus the submission data in column 'xml`
  # names(sub) # nolint
  cn <- c(
    "instance_id", "submitter_id", "submitter", "created_at", "updated_at"
  )
  testthat::expect_equal(names(sub), cn)
})

# usethis::use_r("submission_detail") # nolint
