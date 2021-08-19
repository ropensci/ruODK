test_that("project_list works", {
  vcr::use_cassette("test_project_list0", {
    p <- project_list(
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })
  testthat::expect_true(nrow(p) > 0)

  # project_list returns a tibble
  testthat::expect_equal(class(p), c("tbl_df", "tbl", "data.frame"))

  # Project metadata are the tibble's columns
  cn <- c(
    "id",
    "name",
    "forms",
    "last_submission",
    "app_users",
    "created_at",
    "updated_at",
    "key_id",
    "archived"
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
  skip_on_cran()
  testthat::expect_error(p <- project_list(
    url = NULL,
    un = NULL,
    pw = NULL
  ))
})

test_that("project_list fails on missing URL", {
  skip_on_cran()
  testthat::expect_error(p <- project_list(
    url = NULL,
    un = get_test_un(),
    pw = get_test_pw()
  ))
})

test_that("project_list fails on missing username", {
  skip_on_cran()
  testthat::expect_error(p <- project_list(
    url = get_test_url(),
    un = NULL,
    pw = get_test_pw()
  ))
})

test_that("project_list fails on missing password", {
  skip_on_cran()
  testthat::expect_error(p <- project_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = NULL
  ))
})

test_that("project_list aborts on missing credentials", {
  skip_on_cran()
  testthat::expect_error(p <- project_list(
    url = "",
    un = get_test_un(),
    pw = get_test_pw()
  ))

  testthat::expect_error(p <- project_list(
    url = get_test_url(),
    un = "",
    pw = get_test_pw()
  ))

  testthat::expect_error(p <- project_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = ""
  ))
})

test_that("project_list warns on wrong URL", {
  testthat::expect_error(p <- project_list(
    url = "wrong_url",
    un = get_test_un(),
    pw = get_test_pw()
  ))
})


test_that("project_list warns on wrong credentials", {
  vcr::use_cassette("test_project_list9", {
    testthat::expect_error(p <- project_list(
      url = get_test_url(),
      un = "wrong_username",
      pw = get_test_pw()
    ))
  })

  vcr::use_cassette("test_project_listA", {
    testthat::expect_error(p <- project_list(
      url = get_test_url(),
      un = get_test_un(),
      pw = "wrong_password"
    ))
  })
})

# usethis::use_r("project_list") # nolint
