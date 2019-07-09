test_that("project_list works", {
  p <- project_list(
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_true(nrow(p) > 0)
})


test_that("project_list fails on missing authentication", {
  testthat::expect_error(
    p <- project_list(
      url = Sys.getenv("ODKC_TEST_URL"),
      un = NULL,
      pw = NULL
    )
  )
})
