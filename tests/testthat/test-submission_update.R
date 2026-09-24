test_that("submission_update replaces Submission data", {
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
    "ruodk_subu_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  iid <- ru_uuid()
  submission_create(
    fid = fid,
    xml = ru_test_submission_xml(fid, iid)
  )

  new_iid <- ru_uuid()
  s <- submission_update(
    iid = iid,
    fid = fid,
    xml = ru_test_submission_xml(
      fid,
      new_iid,
      deprecated_id = iid,
      name = "Jo updated"
    )
  )

  testthat::expect_equal(s$current_version$instanceId, new_iid)

  # A stale deprecatedID is rejected by Central.
  testthat::expect_error(
    submission_update(
      iid = iid,
      fid = fid,
      xml = ru_test_submission_xml(
        fid,
        ru_uuid(),
        deprecated_id = iid,
        name = "Jo stale"
      )
    )
  )
})

test_that("submission_update rejects missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    submission_update(iid = "uuid:1", fid = "f", url = url, un = un, pw = pw),
    "single non-empty"
  )
  testthat::expect_error(
    submission_update(
      iid = "uuid:1",
      fid = "f",
      xml = "",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
})

# usethis::use_r("submission_update")  # nolint
