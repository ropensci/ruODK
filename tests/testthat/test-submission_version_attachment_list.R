test_that("submission_version_attachment_list lists version slots", {
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
    "ruodk_vattl_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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

  path <- withr::local_tempfile(fileext = ".jpg")
  writeBin(charToRaw("fake-jpeg-bytes"), path)
  attachment_upload(iid = iid, fid = fid, filename = "photo.jpg", file = path)

  new_iid <- ru_uuid()
  submission_update(
    iid = iid,
    fid = fid,
    xml = ru_test_submission_xml(
      fid,
      new_iid,
      deprecated_id = iid,
      photo = TRUE
    )
  )

  al <- submission_version_attachment_list(iid = iid, fid = fid, vid = new_iid)
  testthat::expect_equal(class(al), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true("photo.jpg" %in% al$name)
  testthat::expect_true(al$exists[al$name == "photo.jpg"])
})

test_that("submission_version_attachment_list rejects a missing vid", {
  testthat::expect_error(
    submission_version_attachment_list(
      iid = "uuid:1",
      fid = "f",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# usethis::use_r("submission_version_attachment_list")  # nolint
