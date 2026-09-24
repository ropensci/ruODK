test_that("form_version_xml returns the version definition", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  fid <- glue::glue(
    "ruodk_verx_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  vx <- form_version_xml(fid = fid, version = "1")
  testthat::expect_true(is.list(vx))

  raw <- form_version_xml(fid = fid, version = "1", parse = FALSE)
  testthat::expect_true(inherits(raw, "xml_document"))
})

test_that("form_version_xml rejects a missing version", {
  testthat::expect_error(
    form_version_xml(
      fid = "f",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# usethis::use_r("form_version_xml")  # nolint
