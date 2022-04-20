context("test-odata_metadata_get.R")

test_that("odata_metadata_get works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  md <- odata_metadata_get(
    get_test_pid(),
    get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(class(md), "list")
})

# usethis::use_r("odata_metadata_get") # nolint
