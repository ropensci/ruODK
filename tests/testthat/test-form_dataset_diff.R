test_that("form_dataset_diff lists Datasets of an entity Form", {
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

  dd <- form_dataset_diff(fid = "report_problem")

  testthat::expect_true(length(dd) >= 1)
  testthat::expect_equal(dd[[1]]$name, "problems")
  testthat::expect_true(length(dd[[1]]$properties) >= 1)
})

test_that("form_dataset_diff is empty for a plain Form", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  fid <- glue::glue(
    "ruodk_diff_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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

  dd <- form_dataset_diff(
    fid = fid,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(length(dd), 0)
})

test_that("form_dataset_diff rejects missing input", {
  testthat::expect_error(
    form_dataset_diff(fid = "f", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_dataset_diff")  # nolint
