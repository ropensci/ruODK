test_that("form_draft_publish makes the Draft the active definition", {
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
    "ruodk_draftp_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  # Same version string as published: allowed in Draft, resolved on publish.
  form_draft_create(fid = fid, xml = ru_test_form_xml(fid))

  p <- form_draft_publish(fid = fid, version = "2")
  testthat::expect_equal(p$success, TRUE)

  fd <- form_detail(fid = fid)
  testthat::expect_equal(fd$version, "2")
})

test_that("form_draft_publish rejects an empty version", {
  testthat::expect_error(
    form_draft_publish(
      fid = "f",
      version = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# usethis::use_r("form_draft_publish")  # nolint
