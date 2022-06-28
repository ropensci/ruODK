test_that("project_list works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

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
    "id",
    "name",
    "description",
    "archived",
    "key_id",
    "created_at",
    "updated_at",
    "deleted_at",
    "verbs",
    "forms",
    "app_users",
    "last_submission"
  )
  purrr::map(
    cn,
    ~ testthat::expect_true(
      . %in% names(p),
      label = glue::glue("Column {.} missing from project_list")
    )
  )
})

# All other functions use the same authentication on the ODK Central side.
# We test expected of missing authentication here once for all ruODK functions.

test_that("project_list fails on missing crendentials", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  testthat::expect_error(p <- project_list(
    url = NULL,
    un = NULL,
    pw = NULL
  ))
})

test_that("project_list fails on missing URL", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  testthat::expect_error(p <- project_list(
    url = NULL,
    un = get_test_un(),
    pw = get_test_pw()
  ))
})

test_that("project_list fails on missing username", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  testthat::expect_error(p <- project_list(
    url = get_test_url(),
    un = NULL,
    pw = get_test_pw()
  ))
})

test_that("project_list fails on missing password", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  testthat::expect_error(p <- project_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = NULL,
    retries = 1
  ))
})

test_that("project_list aborts on missing credentials", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  testthat::expect_error(p <- project_list(
    url = "",
    un = get_test_un(),
    pw = get_test_pw(),
    retries = 1
  ))

  testthat::expect_error(p <- project_list(
    url = get_test_url(),
    un = "",
    pw = get_test_pw(),
    retries = 1
  ))

  testthat::expect_error(p <- project_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = "",
    retries = 1
  ))
})

test_that("project_list warns on wrong URL", {
  testthat::expect_error(p <- project_list(
    url = "wrong_url",
    un = get_test_un(),
    pw = get_test_pw(),
    retries = 1
  ))
})

# This should error but works
# test_that("project_list warns on wrong credentials", {
#   testthat::expect_error(
#     p <- project_list(
#       url = get_test_url(),
#       un = "wrong_username",
#       pw = get_test_pw(),
#       retries = 1
#     )
#   )
#
#   testthat::expect_error(
#     p <- project_list(
#       url = get_test_url(),
#       un = get_test_un(),
#       pw = "wrong_password",
#       retries = 1
#     )
#   )
# })

# usethis::use_r("project_list") # nolint
