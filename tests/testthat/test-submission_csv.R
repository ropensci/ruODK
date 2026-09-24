test_that("submission_csv exports the root table", {
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
    "ruodk_scsv_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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
  submission_create(fid = fid, xml = ru_test_submission_xml(fid, iid))

  csv <- submission_csv(fid = fid)
  testthat::expect_equal(class(csv), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_gte(nrow(csv), 1)
  testthat::expect_true("meta-instanceID" %in% names(csv))
  testthat::expect_true(iid %in% csv$`meta-instanceID`)
})

test_that("submission_csv rejects missing input", {
  testthat::expect_error(
    submission_csv(fid = "f", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_csv")  # nolint
