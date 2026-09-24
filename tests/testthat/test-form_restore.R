test_that("form_restore restores a deleted Form", {
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
    "ruodk_restore_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(
    xml = ru_test_form_xml(fid),
    publish = TRUE,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  httr::DELETE(
    paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
    httr::authenticate(get_test_un(), get_test_pw())
  )

  withr::defer(
    try(
      httr::DELETE(
        paste0(
          get_test_url(),
          "/v1/projects/",
          get_test_pid(),
          "/forms/",
          fid
        ),
        httr::authenticate(get_test_un(), get_test_pw())
      ),
      silent = TRUE
    )
  )

  trash <- form_list(
    pid = get_test_pid(),
    deleted = TRUE,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_true(fid %in% trash$xml_form_id)

  numeric_id <- trash$id[trash$xml_form_id == fid][[1]]
  r <- form_restore(
    pid = get_test_pid(),
    id = numeric_id,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(r$success, TRUE)

  fl <- form_list(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_true(fid %in% fl$xml_form_id)
})

test_that("form_restore rejects a missing id", {
  testthat::expect_error(
    form_restore(
      pid = 1,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single Form ID"
  )
})

# usethis::use_r("form_restore")  # nolint
