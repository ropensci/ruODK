test_that("public_link_update validates properties", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    public_link_update(
      fid = "f",
      link_id = 1,
      properties = list("x"),
      url = url,
      un = un,
      pw = pw
    ),
    "named list"
  )
  testthat::expect_error(
    public_link_update(
      fid = "f",
      link_id = 1,
      properties = list("region" = 42),
      url = url,
      un = un,
      pw = pw
    ),
    "named list"
  )
  testthat::expect_error(
    public_link_update(
      fid = "f",
      properties = list("region" = "North"),
      url = url,
      un = un,
      pw = pw
    ),
    "single Link ID"
  )
})

# Live coverage needs pre-registered Actor Properties on the Project,
# which the shared test instance does not provide. Once such a Project
# exists, post `properties = list("<name>" = "<value>")` and expect the
# returned Link to hold them.

test_that("public_link_update sends properties", {
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
    "ruodk_plu_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  pl <- public_link_create(fid = fid, display_name = "Update test link")

  withr::defer(
    public_link_delete(fid = fid, link_id = pl$id)
  )

  # Unregistered Actor properties are rejected by Central,
  # after the properties reach the request body
  testthat::expect_error(
    public_link_update(
      fid = fid,
      link_id = pl$id,
      properties = list("no-such-property" = "x")
    ),
    "HTTP 400"
  )
})

# usethis::use_r("public_link_update")  # nolint
