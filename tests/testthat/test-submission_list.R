test_that("submission_list works", {
  sl <- submission_list(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  fl <- form_list(
    Sys.getenv("ODKC_TEST_PID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  # submission_list returns a tibble
  testthat::expect_equal(class(sl), c("tbl_df", "tbl", "data.frame"))

  # Submission attributes are the tibble's columns
  cn <- c(
    "instance_id", "submitter_id", "device_id", "created_at", "updated_at"
  )
  testthat::expect_equal(names(sl), cn)

  # Number of submissions (rows) is same as advertised in form_list
  form_list_nsub <- fl %>%
    filter(fid == Sys.getenv("ODKC_TEST_FID")) %>%
    magrittr::extract2("submissions") %>%
    as.numeric()
  testthat::expect_equal(nrow(sl), form_list_nsub)
})

# Tests
# usethis::edit_file("R/submission_list.R")
