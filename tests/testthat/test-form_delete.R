test_that("form_delete deletes a Form", {
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
    "ruodk_fdel_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  dl <- form_delete(fid = fid)
  testthat::expect_true(dl$success)

  fl <- form_list()
  testthat::expect_false(fid %in% fl$fid)
})

test_that("form_delete rejects missing credentials", {
  testthat::expect_error(
    form_delete(
      pid = "1",
      fid = "f",
      url = "",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
  testthat::expect_error(
    form_delete(
      pid = "1",
      fid = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_delete")  # nolint
