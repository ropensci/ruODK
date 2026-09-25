test_that("submission_version_xml shows one version", {
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
    "ruodk_verx_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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

  vx <- submission_version_xml(iid = iid, fid = fid, vid = iid)
  testthat::expect_type(vx, "list")
  testthat::expect_true(length(vx) > 0)
})

test_that("submission_version_xml rejects a missing vid", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    submission_version_xml(
      iid = "uuid:1",
      fid = "f",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
  testthat::expect_error(
    submission_version_xml(
      iid = "uuid:1",
      fid = "f",
      vid = "uuid:2",
      url = "",
      un = un,
      pw = pw
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_version_xml")  # nolint
