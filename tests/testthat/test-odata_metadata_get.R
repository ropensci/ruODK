context("test-odata_metadata_get.R")

test_that("odata_metadata_get works", {
  md <- odata_metadata_get(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_equal(class(md), "list")
})

# Tests code
# usethis::edit_file("R/odata_metadata_get.R")
