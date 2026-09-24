test_that("form_create publishes a new Form from XML", {
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
    "ruodk_test_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()

  f <- form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  testthat::expect_equal(f$xml_form_id, fid)
  testthat::expect_equal(f$state, "open")

  # The new Form is listed with the same id.
  fl <- form_list(pid = get_test_pid())
  testthat::expect_true(fid %in% fl$xml_form_id)
})

test_that("form_create uploads a new Form from an XML file", {
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
    "ruodk_file_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  path <- withr::local_tempfile(fileext = ".xml")
  writeLines(ru_test_form_xml(fid), path)

  f <- form_create(file = path, publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  testthat::expect_equal(f$xml_form_id, fid)
})

test_that("form_create rejects missing or ambiguous input", {
  # Dummy credentials: validation runs before any request is sent.
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    form_create(url = url, un = un, pw = pw),
    "Exactly one"
  )
  testthat::expect_error(
    form_create(
      xml = "<data/>",
      file = withr::local_tempfile(fileext = ".xml"),
      url = url,
      un = un,
      pw = pw
    ),
    "Exactly one"
  )
  testthat::expect_error(
    form_create(
      file = tempfile(fileext = ".txt"),
      url = url,
      un = un,
      pw = pw
    ),
    "File not found"
  )
  bad_ext <- withr::local_tempfile(fileext = ".txt")
  writeLines("not a form", bad_ext)
  testthat::expect_error(
    form_create(file = bad_ext, url = url, un = un, pw = pw),
    "must end in"
  )
})

# usethis::use_r("form_create")  # nolint
