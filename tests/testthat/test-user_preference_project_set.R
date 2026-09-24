test_that("project preferences round-trip", {
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

  s <- user_preference_project_set(
    name = "ruodkTestPref",
    value = TRUE
  )
  testthat::expect_equal(s$success, TRUE)

  d <- user_preference_project_delete(name = "ruodkTestPref")
  testthat::expect_equal(d$success, TRUE)
})

test_that("user_preference_project_set rejects missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    user_preference_project_set(
      name = "",
      value = TRUE,
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
  testthat::expect_error(
    user_preference_project_set(name = "x", url = url, un = un, pw = pw),
    "must be given"
  )
  testthat::expect_error(
    user_preference_project_delete(name = "x", url = "", un = un, pw = pw),
    "Missing ODK Central"
  )
})

# usethis::use_r("user_preference_project_set")  # nolint
