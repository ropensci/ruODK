test_that("form_version_list lists published versions", {
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
    "ruodk_verl_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  form_draft_create(fid = fid, xml = ru_test_form_xml(fid, version = "2"))
  form_draft_publish(fid = fid)

  vl <- form_version_list(fid = fid)
  testthat::expect_equal(class(vl), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true(all(c("version", "xml_form_id") %in% names(vl)))
  testthat::expect_true(all(c("1", "2") %in% vl$version))
})

test_that("form_version_list rejects missing input", {
  testthat::expect_error(
    form_version_list(fid = "f", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_version_list")  # nolint
