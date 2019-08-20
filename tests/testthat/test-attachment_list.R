context("test-attachment_list.R")

test_that("attachment_list works", {
  sl <- submission_list(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )

  al <- attachment_list(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    sl$instance_id[[1]],
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  al %>% knitr::kable(.)

  # attachment_list returns a tibble
  testthat::expect_equal(class(al), c("tbl_df", "tbl", "data.frame"))

  # Attachment attributes are the tibble's columns
  cn <- c("name", "exists")
  testthat::expect_equal(names(al), cn)
})

# Tests code
# usethis::edit_file("R/attachment_list.R")
