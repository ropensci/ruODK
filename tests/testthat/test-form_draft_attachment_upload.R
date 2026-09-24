test_that("form_draft_attachment_upload fills the slot", {
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
  fid <- glue::glue("ruodk_dattu_{ts}") |> as.character()
  csv <- glue::glue("cities_{ts}.csv") |> as.character()
  form_create(xml = ru_test_form_xml(fid, itemset = csv), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  form_draft_create(fid = fid)

  path <- withr::local_tempfile(fileext = ".csv")
  writeLines(c("name,label", "a,Alice"), path)

  u <- form_draft_attachment_upload(
    fid = fid,
    filename = csv,
    file = path,
    content_type = "text/csv"
  )
  testthat::expect_equal(u$name, csv)
  testthat::expect_equal(u$exists, TRUE)

  al <- form_draft_attachment_list(fid = fid)
  testthat::expect_true(al$exists[al$name == csv])

  form_draft_delete(fid = fid)
})

test_that("form_draft_attachment_upload rejects missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    form_draft_attachment_upload(
      fid = "f",
      filename = "",
      file = "/tmp/x",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
  testthat::expect_error(
    form_draft_attachment_upload(
      fid = "f",
      filename = "a.csv",
      file = tempfile(),
      url = url,
      un = un,
      pw = pw
    ),
    "File not found"
  )
})

# usethis::use_r("form_draft_attachment_upload")  # nolint
