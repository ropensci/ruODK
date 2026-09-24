test_that("site preferences round-trip", {
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

  s <- user_preference_site_set(name = "ruodkTestPref", value = "latest")
  testthat::expect_equal(s$success, TRUE)

  d <- user_preference_site_delete(name = "ruodkTestPref")
  testthat::expect_equal(d$success, TRUE)
})

test_that("site preferences reject missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    user_preference_site_set(
      name = "",
      value = "x",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
  testthat::expect_error(
    user_preference_site_delete(name = "x", url = "", un = un, pw = pw),
    "Missing ODK Central"
  )
})

# usethis::use_r("user_preference_site_set")  # nolint
