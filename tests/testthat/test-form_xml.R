test_that("form_xml returns a nested list with parse defaults", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

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
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

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
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

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

test_that("form_xml reads a published version (#129)", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  s <- setup_moved_field_form(submit = FALSE)

  fxml_v1 <- form_xml(
    parse = FALSE,
    pid = get_test_pid(),
    fid = s$fid,
    version = "grp1",
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_true(grepl("/data/mygroup", as.character(fxml_v1)))

  fxml_latest <- form_xml(
    parse = FALSE,
    pid = get_test_pid(),
    fid = s$fid,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_false(grepl("/data/mygroup", as.character(fxml_latest)))

  testthat::expect_error(
    form_xml(
      pid = get_test_pid(),
      fid = s$fid,
      version = "",
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    ),
    "single non-empty"
  )
})

# usethis::use_r("form_xml") # nolint
