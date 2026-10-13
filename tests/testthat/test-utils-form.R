test_that("ru_form_upload reads legacy .xls files", {
  xls <- withr::local_tempfile(fileext = ".xls")
  writeBin(as.raw(1:16), xls)
  up <- ru_form_upload(file = xls)
  testthat::expect_equal(up$content_type, "application/vnd.ms-excel")
  testthat::expect_type(up$body, "raw")
})

# usethis::use_r("ru_form_upload")  # nolint
