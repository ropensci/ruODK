test_that("form_draft_create creates and replaces a Draft", {
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
    "ruodk_draftc_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  d <- form_draft_create(fid = fid, xml = ru_test_form_xml(fid, version = "2"))
  testthat::expect_equal(d$success, TRUE)

  dd <- form_draft_detail(fid = fid)
  testthat::expect_equal(dd$version, "2")

  # Posting again replaces the Draft.
  d <- form_draft_create(fid = fid, xml = ru_test_form_xml(fid, version = "3"))
  testthat::expect_equal(d$success, TRUE)

  dd <- form_draft_detail(fid = fid)
  testthat::expect_equal(dd$version, "3")
})

test_that("form_draft_create copies the published definition", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  fid <- glue::glue(
    "ruodk_draftcopy_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(
    xml = ru_test_form_xml(fid),
    publish = TRUE,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  d <- form_draft_create(
    fid = fid,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(d$success, TRUE)

  dd <- form_draft_detail(
    fid = fid,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(dd$version, "1")
})

test_that("form_draft_create rejects xml and file together", {
  testthat::expect_error(
    form_draft_create(
      fid = "f",
      xml = "<data/>",
      file = withr::local_tempfile(fileext = ".xml"),
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "Pass only one"
  )
})

# usethis::use_r("form_draft_create")  # nolint
