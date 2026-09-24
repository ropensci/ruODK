test_that("public_link_detail shows one Link", {
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
    "ruodk_pld_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  created <- public_link_create(fid = fid, display_name = "Detail test link")

  withr::defer(
    public_link_delete(fid = fid, link_id = created$id)
  )

  pd <- public_link_detail(fid = fid, link_id = created$id)
  testthat::expect_equal(nrow(pd), 1)
  testthat::expect_equal(pd$display_name, "Detail test link")
  testthat::expect_equal(pd$token, created$token)
})

test_that("public_link_detail rejects a missing link id", {
  testthat::expect_error(
    public_link_detail(
      fid = "f",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single Link ID"
  )
})

# usethis::use_r("public_link_detail")  # nolint
