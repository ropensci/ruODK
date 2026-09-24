test_that("public_link_list lists Links of a Form", {
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
    "ruodk_pll_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  pl <- public_link_list(fid = fid)
  testthat::expect_equal(nrow(pl), 0)

  created <- public_link_create(fid = fid, display_name = "List test link")

  withr::defer(
    public_link_delete(fid = fid, link_id = created$id)
  )

  pl <- public_link_list(fid = fid)
  testthat::expect_equal(nrow(pl), 1)
  testthat::expect_equal(pl$display_name, "List test link")
})

test_that("public_link_list rejects missing input", {
  testthat::expect_error(
    public_link_list(fid = "f", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("public_link_list")  # nolint
