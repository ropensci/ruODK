test_that("form_draft_attachment_delete clears uploaded bytes", {
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
  fid <- glue::glue("ruodk_dattdel_{ts}") |> as.character()
  csv <- glue::glue("cities_{ts}.csv") |> as.character()
  form_create(xml = ru_test_form_xml(fid, itemset = csv), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  form_draft_create(fid = fid)

  path <- withr::local_tempfile(fileext = ".csv")
  writeLines(c("name,label", "a,Alice"), path)
  form_draft_attachment_upload(fid = fid, filename = csv, file = path)

  d <- form_draft_attachment_delete(fid = fid, filename = csv)
  testthat::expect_equal(d$success, TRUE)

  al <- form_draft_attachment_list(fid = fid)
  testthat::expect_true(csv %in% al$name)
  testthat::expect_false(al$exists[al$name == csv])

  form_draft_delete(fid = fid)
})

test_that("form_draft_attachment_delete rejects missing input", {
  testthat::expect_error(
    form_draft_attachment_delete(
      fid = "f",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# usethis::use_r("form_draft_attachment_delete")  # nolint
