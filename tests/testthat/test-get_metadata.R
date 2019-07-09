context("test-get_metadata.R")

test_that("get_metadata works", {
  md <- get_metadata(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_equal(class(md), "list")
  testthat::expect_equal(
    attr(md$Edmx$DataServices$Schema$EntityContainer, "Name"),
    Sys.getenv("ODKC_TEST_FID")
  )
})
