test_that("form_xml works", {
  fxml <- form_xml(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_equal(class(fxml), "list")
})
