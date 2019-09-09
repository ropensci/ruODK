context("test-odata_submission_get.R")

test_that("odata_submission_get works with one known dataset", {
  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  fresh_parsed <- fresh_raw %>% odata_submission_parse()
  testthat::expect_gte(nrow(fresh_parsed), length(fresh_raw$value))
})


test_that("odata_submission_get skip omits number of results", {
  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  fresh_parsed <- fresh_raw %>% odata_submission_parse()

  skip_raw <- odata_submission_get(
    skip = 1,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  skip_parsed <- skip_raw %>% odata_submission_parse()

  testthat::expect_true(nrow(fresh_parsed) == nrow(skip_parsed) + 1)
})

test_that("odata_submission_get top limits number of results", {
  top_raw <- odata_submission_get(
    top = 1,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  top_parsed <- top_raw %>% odata_submission_parse()

  testthat::expect_true(nrow(top_parsed) == 1)
})


test_that("odata_submission_get count returns total number or rows", {
  x_raw <- odata_submission_get(
    count = TRUE,
    top = 1,
    wkt = TRUE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
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
