test_that("form_version_attachment_download fails without bytes", {
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

  ts <- format(Sys.time(), "%Y%m%d%H%M%S")
  fid <- glue::glue("ruodk_vattd_{ts}") |> as.character()
  csv <- glue::glue("cities_{ts}.csv") |> as.character()
  form_create(xml = ru_test_form_xml(fid, itemset = csv), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  # No bytes were ever uploaded for this slot (Central answers 404).
  testthat::expect_error(
    form_version_attachment_download(fid = fid, version = "1", filename = csv)
  )
})

test_that("form_version_attachment_download rejects missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    form_version_attachment_download(
      fid = "f",
      version = "1",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
})

# usethis::use_r("form_version_attachment_download")  # nolint
