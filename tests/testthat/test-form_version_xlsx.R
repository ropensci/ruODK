test_that("form_version_xlsx fails for XML-created versions", {
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
    "ruodk_verxlsx_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  # XML-created versions have no spreadsheet source (Central answers 404).
  testthat::expect_error(
    form_version_xlsx(fid = fid, version = "1")
  )
})

test_that("form_version_xlsx rejects a missing version", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    form_version_xlsx(fid = "f", url = url, un = un, pw = pw),
    "single non-empty"
  )
  testthat::expect_error(
    form_version_xlsx(
      fid = "f",
      version = "1",
      dest = 123,
      url = url,
      un = un,
      pw = pw
    ),
    "single file path"
  )
})

# usethis::use_r("form_version_xlsx")  # nolint
