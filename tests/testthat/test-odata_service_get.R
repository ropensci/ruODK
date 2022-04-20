context("test-odata_service_get.R")

test_that("odata_service_get works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  svc <- odata_service_get(
    get_test_pid(),
    get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  testthat::expect_equal(class(svc), c("tbl_df", "tbl", "data.frame"))
  cn <- c("name", "kind", "url")
  testthat::expect_equal(names(svc), cn)
})

# usethis::use_r("odata_service_get") # nolint
