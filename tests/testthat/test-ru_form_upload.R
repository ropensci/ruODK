test_that("ru_form_upload passes XML through", {
  parts <- ru_form_upload(xml = "<data/>")
  testthat::expect_equal(parts$body, "<data/>")
  testthat::expect_equal(parts$content_type, "application/xml")
  testthat::expect_equal(length(parts$extra_headers), 0)
})

test_that("ru_form_upload reads definition files by extension", {
  xml_path <- withr::local_tempfile(fileext = ".xml")
  writeLines("<data/>", xml_path)
  parts <- ru_form_upload(file = xml_path)
  testthat::expect_equal(parts$body, "<data/>")
  testthat::expect_equal(parts$content_type, "application/xml")

  xlsx_path <- withr::local_tempfile(fileext = ".xlsx")
  writeBin(charToRaw("fake-xlsx"), xlsx_path)
  parts <- ru_form_upload(file = xlsx_path, xls_form_id_fallback = "fid")
  testthat::expect_equal(
    parts$content_type,
    paste0(
      "application/vnd.openxmlformats-officedocument.",
      "spreadsheetml.sheet"
    )
  )
  testthat::expect_equal(
    parts$extra_headers[["X-XlsForm-FormId-Fallback"]],
    "fid"
  )
})

test_that("ru_form_upload rejects missing files and extensions", {
  testthat::expect_error(
    ru_form_upload(file = tempfile()),
    "File not found"
  )
  bad_ext <- withr::local_tempfile(fileext = ".txt")
  writeLines("not a form", bad_ext)
  testthat::expect_error(
    ru_form_upload(file = bad_ext),
    "must end in"
  )
  testthat::expect_error(
    ru_form_upload(file = NA_character_),
    "single file path"
  )
})

# usethis::use_r("ru_form_upload")  # nolint
