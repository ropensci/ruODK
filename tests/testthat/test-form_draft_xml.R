test_that("form_draft_xml returns the Draft definition", {
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
    "ruodk_draftx_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid))

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  dx <- form_draft_xml(fid = fid)
  testthat::expect_true(is.list(dx))

  raw <- form_draft_xml(fid = fid, parse = FALSE)
  testthat::expect_true(inherits(raw, "xml_document"))
})

test_that("form_draft_xml rejects missing input", {
  testthat::expect_error(
    form_draft_xml(fid = "f", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_draft_xml")  # nolint
