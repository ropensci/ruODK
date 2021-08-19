test_that("project_detail works", {
  vcr::use_cassette("test_project_detail0", {
    p <- project_detail(
      get_test_pid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })
  testthat::expect_true(nrow(p) == 1)
  testthat::expect_true("name" %in% names(p))

  # project_detail returns a tibble
  testthat::expect_equal(class(p), c("tbl_df", "tbl", "data.frame"))

  # Project metadata are the tibble's columns
  cn <- c(
    "id", "name", "forms", "app_users", "last_submission",
    "created_at", "updated_at", "archived", "verbs"
  )
  testthat::expect_equal(names(p), cn)
})

test_that("project_detail aborts on missing credentials", {

  skip_on_cran()

    testthat::expect_error(
      p <- project_detail(
        get_test_pid(),
        url = "",
        un = get_test_un(),
        pw = get_test_pw()
      )
    )

    testthat::expect_error(
      p <- project_detail(
        get_test_pid(),
        url = get_test_url(),
        un = "",
        pw = get_test_pw()
      )
    )

    testthat::expect_error(
      p <- project_detail(
        get_test_pid(),
        url = get_test_url(),
        un = get_test_un(),
        pw = ""
      )
    )
})

test_that("project_detail warns on wrong credentials", {
  skip_on_cran()

    testthat::expect_error(
      p <- project_detail(
        111111,
        url = get_test_url(),
        un = get_test_un(),
        pw = get_test_pw()
      )
    )

    testthat::expect_error(
      p <- project_detail(
        get_test_pid(),
        url = "wrong_url",
        un = get_test_un(),
        pw = get_test_pw()
      )
    )

  vcr::use_cassette("test_project_detail6", {
    testthat::expect_error(
      p <- project_detail(
        get_test_pid(),
        url = get_test_url(),
        un = "wrong_username",
        pw = get_test_pw()
      )
    )
  })

  vcr::use_cassette("test_project_detail7", {
    testthat::expect_error(
      p <- project_detail(
        get_test_pid(),
        url = get_test_url(),
        un = get_test_un(),
        pw = "wrong_password"
      )
    )
  })
})

# usethis::use_r("project_detail") # nolint
