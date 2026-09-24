test_that("submission_version_attachment_download returns version bytes", {
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
    "ruodk_vattd_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid, photo = TRUE), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  iid <- ru_uuid()
  submission_create(
    fid = fid,
    xml = ru_test_submission_xml(fid, iid, photo = TRUE)
  )

  bytes <- charToRaw("fake-jpeg-bytes")
  path <- withr::local_tempfile(fileext = ".jpg")
  writeBin(bytes, path)
  attachment_upload(iid = iid, fid = fid, filename = "photo.jpg", file = path)

  dest <- submission_version_attachment_download(
    iid = iid,
    fid = fid,
    vid = iid,
    filename = "photo.jpg"
  )
  testthat::expect_equal(readBin(dest, "raw", file.info(dest)$size), bytes)
})

test_that("submission_version_attachment_download rejects missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    submission_version_attachment_download(
      iid = "uuid:1",
      fid = "f",
      vid = "uuid:2",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
})

# usethis::use_r("submission_version_attachment_download")  # nolint
