test_that("user_preference_project_delete rejects missing input", {
  testthat::expect_error(
    user_preference_project_delete(
      name = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# Live coverage lives in test-user_preference_project_set.R, which
# round-trips project preference set and delete on the test server.

test_that("user_preference_project_delete reports named responses", {
  named_response <- function(...) {
    httr2::response(
      200,
      headers = list(`Content-Type` = "application/json"),
      body = charToRaw('{"success":true}')
    )
  }
  testthat::local_mocked_bindings(ru_http_request = named_response)

  # A named response body is cleaned to names
  d <- user_preference_project_delete(
    pid = 1,
    name = "x",
    url = "http://example.com",
    un = "u",
    pw = "p"
  )
  testthat::expect_true(d$success)
})

# usethis::use_r("user_preference_project_delete")  # nolint

# usethis::use_r("user_preference_project_delete")  # nolint
