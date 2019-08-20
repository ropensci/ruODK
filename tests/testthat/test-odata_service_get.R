context("test-odata_service_get.R")

test_that("odata_service_get works", {
  pid <- Sys.getenv("ODKC_TEST_PID")
  fid <- Sys.getenv("ODKC_TEST_FID")
  url <- Sys.getenv("ODKC_TEST_URL")
  un <- Sys.getenv("ODKC_TEST_UN")
  pw <- Sys.getenv("ODKC_TEST_PW")

  svc <- odata_service_get(pid, fid, url = url, un = un, pw = pw)

  testthat::expect_equal(class(svc), c("tbl_df", "tbl", "data.frame"))
  cn <- c("name", "kind", "url")
  testthat::expect_equal(names(svc), cn)
})

# Tests code
# usethis::edit_file("R/odata_service_get.R")
