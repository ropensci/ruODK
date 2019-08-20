test_that("submission_detail works", {
  sl <- submission_list(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )

  sub <- submission_detail(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    sl$instance_id[[1]],
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )

  # submission_detail returns a tibble
  testthat::expect_equal(class(sub), c("tbl_df", "tbl", "data.frame"))


  # The details for one submission return exactly one row
  testthat::expect_equal(nrow(sub), 1)

  # The columns are metadata, plus the submission data in column 'xml`
  names(sub)
  cn <- c(
    "instance_id", "submitter_id", "submitter", "created_at", "updated_at"
  )
  testthat::expect_equal(names(sub), cn)
})

# Tests code
# usethis::edit_file("R/submission_detail.R")
