test_that("form_draft_attachment_list lists expected files", {
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

  ts <- format(Sys.time(), "%Y%m%d%H%M%S")
  fid <- glue::glue("ruodk_dattl_{ts}") |> as.character()
  csv <- glue::glue("cities_{ts}.csv") |> as.character()
  form_create(xml = ru_test_form_xml(fid, itemset = csv), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  form_draft_create(fid = fid)

  al <- form_draft_attachment_list(fid = fid)
  testthat::expect_equal(class(al), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true(csv %in% al$name)
  testthat::expect_false(al$exists[al$name == csv])

  form_draft_delete(fid = fid)
})

test_that("form_draft_attachment_list rejects missing input", {
  testthat::expect_error(
    form_draft_attachment_list(
      fid = "f",
      url = "",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_draft_attachment_list")  # nolint
