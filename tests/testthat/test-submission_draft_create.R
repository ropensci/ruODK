test_that("submission_draft_create creates a Draft Submission", {
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
    "ruodk_dsubc_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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
  s <- submission_draft_create(
    fid = fid,
    xml = ru_test_submission_xml(fid, iid)
  )
  testthat::expect_equal(s$instance_id, iid)

  testthat::expect_error(
    submission_draft_create(fid = fid, xml = ru_test_submission_xml(fid, iid))
  )
})

test_that("submission_draft_create rejects missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    submission_draft_create(fid = "f", url = url, un = un, pw = pw),
    "single non-empty"
  )
})

# usethis::use_r("submission_draft_create")  # nolint
