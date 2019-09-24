test_that("project_list works", {
  p <- project_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_true(nrow(p) > 0)

  # project_list returns a tibble
  testthat::expect_equal(class(p), c("tbl_df", "tbl", "data.frame"))

  # Project metadata are the tibble's columns
  cn <- c(
    "id", "name", "forms", "app_users",
    "created_at", "updated_at", "last_submission", "archived"
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
      un = get_test_un(),
      pw = get_test_pw()
    )
  )
})

test_that("project_list fails on missing username", {
  testthat::expect_error(
    p <- project_list(
      url = get_test_url(),
      un = NULL,
      pw = get_test_pw()
    )
  )
})

test_that("project_list fails on missing password", {
  testthat::expect_error(
    p <- project_list(
      url = get_test_url(),
      un = get_test_un(),
      pw = NULL
    )
  )
})

test_that("project_list aborts on missing credentials", {
  testthat::expect_error(
    p <- project_list(
      url = "",
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  testthat::expect_error(
    p <- project_list(
      url = get_test_url(),
      un = "",
      pw = get_test_pw()
    )
  )

  testthat::expect_error(
    p <- project_list(
      url = get_test_url(),
      un = get_test_un(),
      pw = ""
    )
  )
})

test_that("project_list warns on wrong credentials", {
  testthat::expect_error(
    p <- project_list(
      url = "wrong_url",
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  testthat::expect_error(
    p <- project_list(
      url = get_test_url(),
      un = "wrong_username",
      pw = get_test_pw()
    )
  )

  testthat::expect_error(
    p <- project_list(
      url = get_test_url(),
      un = get_test_un(),
      pw = "wrong_password"
    )
  )
})

# Tests code
# usethis::edit_file("R/project_list.R")
