test_that("form_xml returns a nested list with parse defaults", {
  fxml <- form_xml(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(class(fxml), "list")
})

test_that("form_xml returns a nested list with parse=TRUE", {
  fxml <- form_xml(
    parse = TRUE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(class(fxml), "list")
})

test_that("form_xml returns an xml_document with parse=FALSE", {
  fxml <- form_xml(
    parse = FALSE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(class(fxml), c("xml_document", "xml_node"))
})


# Tests code
# usethis::edit_file("R/form_xml.R")
