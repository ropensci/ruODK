test_that("submission_create creates a Submission", {
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
    "ruodk_subc_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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
  s <- submission_create(
    fid = fid,
    xml = ru_test_submission_xml(fid, iid, photo = TRUE)
  )

  testthat::expect_equal(s$instance_id, iid)

  # A duplicate instanceID is rejected by Central.
  testthat::expect_error(
    submission_create(
      fid = fid,
      xml = ru_test_submission_xml(fid, iid, photo = TRUE)
    )
  )

  # The new Submission is listed with the same instanceID.
  sl <- submission_list(pid = get_test_pid(), fid = fid)
  testthat::expect_true(iid %in% sl$instance_id)
})

test_that("submission_create rejects missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    submission_create(fid = "some_form", url = url, un = un, pw = pw),
    "single non-empty"
  )
  testthat::expect_error(
    submission_create(fid = "some_form", xml = "", url = url, un = un, pw = pw),
    "single non-empty"
  )
  testthat::expect_error(
    submission_create(xml = "<data/>", url = "", un = un, pw = pw),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_create")  # nolint
