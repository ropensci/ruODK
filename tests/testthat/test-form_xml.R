test_that("form_xml returns a nested list with parse defaults", {
  fxml <- form_xml(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_equal(class(fxml), "list")
})

test_that("form_xml returns a nested list with parse=TRUE", {
  fxml <- form_xml(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    parse = TRUE,
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_equal(class(fxml), "list")
})

test_that("form_xml returns an xml_document with parse=FALSE", {
  fxml <- form_xml(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    parse = FALSE,
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_equal(class(fxml), c("xml_document", "xml_node"))
})


# Tests code
# usethis::edit_file("R/form_xml.R")
