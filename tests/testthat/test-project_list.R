test_that("project_list works", {
  p <- project_list(
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_true(nrow(p) > 0)

  # project_list returns a tibble
  testthat::expect_equal(class(p), c("tbl_df", "tbl", "data.frame"))

  # Project metadata are the tibble's columns
  cn <- c(
    "id", "name", "forms", "app_users",
    "last_submission", "created_at", "updated_at", "archived"
  )
  testthat::expect_equal(names(p), cn)
})

# All other functions use the same authentication on the ODK Central side.
# We test expected of missing authentication here once for all ruODK functions.

test_that("project_list fails on missing crendentials", {
  testthat::expect_error(
    p <- project_list(
      url = NULL,
      un = NULL,
      pw = NULL
    )
  )
})

test_that("project_list fails on missing URL", {
  testthat::expect_error(
    p <- project_list(
      url = NULL,
      un = Sys.getenv("ODKC_TEST_UN"),
      pw = Sys.getenv("ODKC_TEST_PW")
    )
  )
})



test_that("project_list fails on missing username", {
  testthat::expect_error(
    p <- project_list(
      url = Sys.getenv("ODKC_TEST_URL"),
      un = NULL,
      pw = Sys.getenv("ODKC_TEST_PW")
    )
  )
})

test_that("project_list fails on missing password", {
  testthat::expect_error(
    p <- project_list(
      url = Sys.getenv("ODKC_TEST_URL"),
      un = Sys.getenv("ODKC_TEST_UN"),
      pw = NULL
    )
  )
})
