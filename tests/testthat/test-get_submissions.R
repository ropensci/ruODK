context("test-get_submissions.R")

test_that("get_submissions works with one known dataset", {
  fresh_raw <- get_submissions(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  fresh_parsed <- fresh_raw %>% parse_submissions()
  testthat::expect_gte(nrow(fresh_parsed), length(fresh_raw$value))
})
