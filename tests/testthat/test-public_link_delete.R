test_that("public_link_delete removes a Link", {
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
    "ruodk_pldel_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  created <- public_link_create(fid = fid, display_name = "Delete test link")

  d <- public_link_delete(fid = fid, link_id = created$id)
  testthat::expect_equal(d$success, TRUE)

  # The deleted Link is gone.
  testthat::expect_error(public_link_detail(fid = fid, link_id = created$id))
})

test_that("public_link_delete rejects a missing link id", {
  testthat::expect_error(
    public_link_delete(
      fid = "f",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single Link ID"
  )
})

# usethis::use_r("public_link_delete")  # nolint
