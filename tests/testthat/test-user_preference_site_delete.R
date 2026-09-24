test_that("user_preference_site_delete rejects missing input", {
  testthat::expect_error(
    user_preference_site_delete(
      name = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# Live coverage lives in test-user_preference_site_set.R, which
# round-trips site preference set and delete on the test server.

# usethis::use_r("user_preference_site_delete")  # nolint
