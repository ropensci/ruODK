context("test-get_submissions.R")

test_that("get_submissions works with one known dataset", {
  data_url <- Sys.getenv("ODKC_TEST_URL")
  fresh_raw <- get_submissions(data_url)
  fresh_parsed <- fresh_raw %>% parse_submissions()
  expect_gte(nrow(fresh_parsed), 2) # submissions at the time of writing
})
