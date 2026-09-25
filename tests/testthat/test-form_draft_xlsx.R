test_that("form_draft_xlsx fails for Drafts without spreadsheet source", {
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
    "ruodk_dxlsx_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  # Draft state: no publish, so a Draft exists
  form_create(xml = ru_test_form_xml(fid))

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  # XML-created Drafts have no spreadsheet source (Central answers 404).
  testthat::expect_error(
    form_draft_xlsx(
      fid = fid,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )
})

test_that("form_draft_xlsx rejects a missing dest", {
  testthat::expect_error(
    form_draft_xlsx(
      fid = "f",
      dest = 123,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single file path"
  )
})

# usethis::use_r("form_draft_xlsx")  # nolint
