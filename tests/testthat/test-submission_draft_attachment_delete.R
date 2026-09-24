test_that("submission_draft_attachment_delete clears bytes", {
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
    "ruodk_dsubadel_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid, photo = TRUE))

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  iid <- ru_uuid()
  submission_draft_create(
    fid = fid,
    xml = ru_test_submission_xml(fid, iid, photo = TRUE)
  )

  path <- withr::local_tempfile(fileext = ".jpg")
  writeBin(charToRaw("fake-jpeg-bytes"), path)
  submission_draft_attachment_upload(
    iid = iid,
    fid = fid,
    filename = "photo.jpg",
    file = path
  )

  d <- submission_draft_attachment_delete(
    iid = iid,
    fid = fid,
    filename = "photo.jpg"
  )
  testthat::expect_equal(d$success, TRUE)

  al <- submission_draft_attachment_list(iid = iid, fid = fid)
  testthat::expect_false(al$exists[al$name == "photo.jpg"])
})

test_that("submission_draft_attachment_delete rejects missing input", {
  testthat::expect_error(
    submission_draft_attachment_delete(
      iid = "uuid:1",
      fid = "f",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# usethis::use_r("submission_draft_attachment_delete")  # nolint
