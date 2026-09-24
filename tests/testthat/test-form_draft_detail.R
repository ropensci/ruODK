test_that("form_draft_detail shows Draft metadata", {
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
    "ruodk_draftd_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid))

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  dd <- form_draft_detail(fid = fid)
  testthat::expect_equal(dd$xml_form_id, fid)
  testthat::expect_equal(dd$version, "1")
  testthat::expect_true(!is.null(dd$draft_token))
})

test_that("form_draft_detail rejects missing input", {
  testthat::expect_error(
    form_draft_detail(fid = "f", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_draft_detail")  # nolint
