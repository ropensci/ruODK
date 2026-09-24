test_that("form_version_detail shows one published version", {
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
    "ruodk_verd_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  vd <- form_version_detail(fid = fid, version = "1")
  testthat::expect_equal(nrow(vd), 1)
  testthat::expect_equal(vd$fid, fid)
  testthat::expect_equal(vd$version, "1")
})

test_that("form_version_detail rejects a missing version", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    form_version_detail(fid = "f", url = url, un = un, pw = pw),
    "single non-empty"
  )
  testthat::expect_error(
    form_version_detail(fid = "f", version = "1", url = "", un = un, pw = pw),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_version_detail")  # nolint
