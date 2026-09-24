test_that("role_list lists all Roles", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  rl <- role_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(class(rl), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true(all(c("id", "name", "system", "verbs") %in% names(rl)))
  testthat::expect_true("admin" %in% rl$system)
})

test_that("role_list rejects missing input", {
  testthat::expect_error(
    role_list(url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("role_list")  # nolint
