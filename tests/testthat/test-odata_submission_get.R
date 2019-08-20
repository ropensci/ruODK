context("test-odata_submission_get.R")

test_that("odata_submission_get works with one known dataset", {
  fresh_raw <- odata_submission_get(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  fresh_parsed <- fresh_raw %>% odata_submission_parse()
  testthat::expect_gte(nrow(fresh_parsed), length(fresh_raw$value))
})


test_that("odata_submission_get skip omits number of results", {
  fresh_raw <- odata_submission_get(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  fresh_parsed <- fresh_raw %>% odata_submission_parse()

  skip_raw <- odata_submission_get(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    skip = 1,
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  skip_parsed <- skip_raw %>% odata_submission_parse()

  testthat::expect_true(nrow(fresh_parsed) == nrow(skip_parsed) + 1)
})

test_that("odata_submission_get top limits number of results", {
  top_raw <- odata_submission_get(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    top = 1,
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  top_parsed <- top_raw %>% odata_submission_parse()

  testthat::expect_true(nrow(top_parsed) == 1)
})


test_that("odata_submission_get count returns total number or rows", {
  x_raw <- odata_submission_get(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    count = TRUE,
    top = 1,
    wkt = TRUE,
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  x_parsed <- x_raw %>% odata_submission_parse()

  # Returned: one row
  testthat::expect_true(nrow(x_parsed) == 1)

  # Count: shows all records
  testthat::expect_true("@odata.count" %in% names(x_raw))
  testthat::expect_gt(x_raw$`@odata.count`, nrow(x_parsed))
})


# Tests code
# usethis::edit_file("R/odata_submission_get.R")
