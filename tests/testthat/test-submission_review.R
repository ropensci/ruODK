test_that("submission_review sets the review state", {
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
    "ruodk_subr_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(
    xml = ru_test_form_xml(fid),
    publish = TRUE
  )

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

  s <- submission_review(iid = iid, fid = fid, review_state = "approved")
  testthat::expect_equal(s$review_state, "approved")

  s <- submission_review(iid = iid, fid = fid, review_state = "hasIssues")
  testthat::expect_equal(s$review_state, "hasIssues")
})

test_that("submission_review rejects a missing or invalid review state", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    submission_review(iid = "uuid:1", fid = "f", url = url, un = un, pw = pw),
    "one of"
  )
  testthat::expect_error(
    submission_review(
      iid = "uuid:1",
      fid = "f",
      review_state = "archived",
      url = url,
      un = un,
      pw = pw
    ),
    "one of"
  )
  testthat::expect_error(
    submission_review(
      iid = "uuid:1",
      fid = "f",
      review_state = "approved",
      url = "",
      un = un,
      pw = pw
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_review")  # nolint
