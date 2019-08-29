context("test-odata_service_get.R")

test_that("odata_service_get works", {
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

# Tests code
# usethis::edit_file("R/odata_service_get.R")
