test_that("form_xml returns a nested list with parse defaults", {
  vcr::use_cassette("test_fid_form_xml0", {
    fxml <- form_xml(
      pid = get_test_pid(),
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })
  testthat::expect_equal(class(fxml), "list")
})

test_that("form_xml returns a nested list with parse=TRUE", {
  vcr::use_cassette("test_fid_form_xml1", {
    fxml <- form_xml(
      parse = TRUE,
      pid = get_test_pid(),
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })
  testthat::expect_equal(class(fxml), "list")
})

test_that("form_xml returns an xml_document with parse=FALSE", {
  vcr::use_cassette("test_fid_form_xml2", {
    fxml <- form_xml(
      parse = FALSE,
      pid = get_test_pid(),
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })
  testthat::expect_equal(class(fxml), c("xml_document", "xml_node"))
})

# usethis::use_r("form_xml") # nolint
