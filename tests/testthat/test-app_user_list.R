test_that("app_user_list lists App Users", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  au <- app_user_list(pid = get_test_pid())
  testthat::expect_s3_class(au, "tbl_df")
})

test_that("app_user_list rejects missing credentials", {
  testthat::expect_error(
    app_user_list(
      pid = 1,
      url = "",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("app_user_list")  # nolint
