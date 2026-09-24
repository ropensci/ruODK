test_that("form_update changes a Form's state", {
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
    "ruodk_state_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  xml <- ru_test_form_xml(fid)
  form_create(xml = xml, publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  f <- form_update(fid = fid, state = "closing")
  testthat::expect_equal(f$xml_form_id, fid)
  testthat::expect_equal(f$state, "closing")

  fd <- form_detail(fid = fid)
  testthat::expect_equal(fd$state, "closing")

  f <- form_update(fid = fid, state = "open")
  testthat::expect_equal(f$state, "open")
})

test_that("form_update rejects a missing or invalid state", {
  testthat::expect_error(
    form_update(fid = "some_form", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
  # Dummy credentials: validation runs before any request is sent.
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    form_update(
      fid = "some_form",
      state = "archived",
      url = url,
      un = un,
      pw = pw
    ),
    "one of"
  )
  testthat::expect_error(
    form_update(fid = "some_form", url = url, un = un, pw = pw),
    "one of"
  )
})

# usethis::use_r("form_update")  # nolint
