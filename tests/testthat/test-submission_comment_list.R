test_that("submission_comment_list returns comments of a Submission", {
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
    "ruodk_coml_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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

  # A fresh Submission has no comments.
  cl <- submission_comment_list(iid = iid, fid = fid)
  testthat::expect_equal(nrow(cl), 0)

  submission_comment_create(iid = iid, fid = fid, body = "Looks good.")

  cl <- submission_comment_list(iid = iid, fid = fid)
  testthat::expect_equal(nrow(cl), 1)
  testthat::expect_equal(cl$body, "Looks good.")
  testthat::expect_true(is.numeric(cl$actor_id) || is.integer(cl$actor_id))
})

test_that("submission_comment_list rejects missing input", {
  testthat::expect_error(
    submission_comment_list(
      iid = "uuid:1",
      fid = "f",
      url = "",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_comment_list")  # nolint
