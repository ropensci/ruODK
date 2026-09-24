test_that("submission_draft_list lists Draft Submissions", {
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
    "ruodk_dsubl_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid))

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  empty <- submission_draft_list(fid = fid)
  testthat::expect_equal(nrow(empty), 0)

  iid <- ru_uuid()
  submission_draft_create(fid = fid, xml = ru_test_submission_xml(fid, iid))

  sl <- submission_draft_list(fid = fid)
  testthat::expect_gte(nrow(sl), 1)
  testthat::expect_true(iid %in% sl$instance_id)
})

test_that("submission_draft_list rejects missing input", {
  testthat::expect_error(
    submission_draft_list(fid = "f", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_draft_list")  # nolint
