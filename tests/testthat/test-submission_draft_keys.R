test_that("submission_draft_keys returns a tibble", {
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
    "ruodk_dsubk_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid))

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  # Unencrypted Forms hold no keys.
  kl <- submission_draft_keys(fid = fid)
  testthat::expect_equal(class(kl), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_equal(nrow(kl), 0)
})

test_that("submission_draft_keys rejects missing input", {
  testthat::expect_error(
    submission_draft_keys(fid = "f", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_draft_keys")  # nolint
