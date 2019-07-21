test_that("project_detail works", {
  p <- project_detail(
    2,
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_true(nrow(p) == 1)
  testthat::expect_true("name" %in% names(p))
})
