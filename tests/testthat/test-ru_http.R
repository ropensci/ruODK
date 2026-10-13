test_that("ru_http_request needs a path for query strings", {
  testthat::expect_error(
    ru_http_request("GET", "http://localhost", query = list(a = 1)),
    "needs a path"
  )
})

# usethis::use_r("ru_http")  # nolint
