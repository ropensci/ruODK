test_that("submission_changes shows edits between versions", {
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
    "ruodk_chg_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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

  new_iid <- ru_uuid()
  submission_update(
    iid = iid,
    fid = fid,
    xml = ru_test_submission_xml(
      fid,
      new_iid,
      deprecated_id = iid,
      name = "Jo updated"
    )
  )

  d <- submission_changes(iid = iid, fid = fid)
  testthat::expect_true(new_iid %in% names(d))

  paths <- purrr::map(d[[new_iid]], "path")
  testthat::expect_true(any(purrr::map_lgl(paths, ~ "name" %in% .x)))
})

test_that("submission_changes rejects missing input", {
  testthat::expect_error(
    submission_changes(
      iid = "uuid:1",
      fid = "f",
      url = "",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_changes")  # nolint
