test_that("submission_draft_export downloads the ZIP", {
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
    "ruodk_dsube_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid))

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  iid <- ru_uuid()
  submission_draft_create(fid = fid, xml = ru_test_submission_xml(fid, iid))

  zip <- submission_draft_export(fid = fid)
  testthat::expect_true(file.exists(zip))
  testthat::expect_gt(file.info(zip)$size, 0)

  files <- utils::unzip(zip, list = TRUE)
  testthat::expect_true(any(grepl("\\.csv$", files$Name)))
})

test_that("submission_draft_export rejects a missing dest", {
  testthat::expect_error(
    submission_draft_export(
      fid = "f",
      dest = 123,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single file path"
  )
})

# usethis::use_r("submission_draft_export")  # nolint
