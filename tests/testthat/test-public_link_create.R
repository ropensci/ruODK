test_that("public_link_create creates a Link", {
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
    "ruodk_plc_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  pl <- public_link_create(fid = fid, display_name = "Create test link")
  testthat::expect_equal(pl$display_name, "Create test link")
  testthat::expect_true(!is.null(pl$token) && nzchar(pl$token))

  withr::defer(
    public_link_delete(fid = fid, link_id = pl$id)
  )

  once <- public_link_create(
    fid = fid,
    display_name = "Once test link",
    once = TRUE
  )
  testthat::expect_equal(once$once, TRUE)

  withr::defer(
    public_link_delete(fid = fid, link_id = once$id)
  )
})

test_that("public_link_create rejects missing or invalid input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    public_link_create(
      fid = "f",
      display_name = "",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
  testthat::expect_error(
    public_link_create(
      fid = "f",
      display_name = "x",
      once = "yes",
      url = url,
      un = un,
      pw = pw
    ),
    "TRUE or FALSE"
  )
})

# usethis::use_r("public_link_create")  # nolint
