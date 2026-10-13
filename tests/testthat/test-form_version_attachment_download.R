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
  testthat::expect_error(
    form_version_attachment_download(
      fid = "f",
      version = "",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
  testthat::expect_error(
    form_version_attachment_download(
      fid = "f",
      version = "1",
      filename = "a.csv",
      dest = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "single file path"
  )
})

test_that("form_version_attachment_download downloads version bytes", {
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

  form_draft_create(
    fid = fid,
    xml = ru_test_form_xml(fid, version = "2", itemset = csv)
  )

  path <- withr::local_tempfile(fileext = ".csv")
  writeLines(c("name,label", "a,Alice"), path)
  form_draft_attachment_upload(
    fid = fid,
    filename = csv,
    file = path,
    content_type = "text/csv"
  )
  form_draft_publish(fid = fid)

  dest <- withr::local_tempfile(fileext = ".csv")
  out <- form_version_attachment_download(
    fid = fid,
    version = "2",
    filename = csv,
    dest = dest
  )
  testthat::expect_equal(out, dest)
  testthat::expect_true(fs::file_exists(out))
  content <- readLines(out, warn = FALSE)
  testthat::expect_true(any(grepl("Alice", content)))
})

# usethis::use_r("form_version_attachment_download")  # nolint
