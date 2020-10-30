test_that("form_schema_ext v8 returns a tibble with defaults", {
  fsx <- form_schema_ext(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  testthat::expect_true(tibble::is_tibble(fsx))
})

test_that("form_schema_ext v8 in a form with no languages", {
  fsx <- form_schema_ext(
    svc ="https://sandbox.central.getodk.org/v1/projects/132/forms/sample_no_language.svc",
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  testthat::expect_true(tibble::is_tibble(fsx))
})

test_that("form_schema_ext v8 in a form with label languages", {
  fsx <- form_schema_ext(
    svc = "https://sandbox.central.getodk.org/v1/projects/132/forms/sample_label_language.svc",
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  testthat::expect_true(tibble::is_tibble(fsx))
})

test_that("form_schema_ext v8 in a form with label and choices languages", {
  fsx <- form_schema_ext(
    svc = "https://sandbox.central.getodk.org/v1/projects/132/forms/sample_label_and_choices_language.svc",
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  testthat::expect_true(tibble::is_tibble(fsx))
})
# usethis::edit_file("R/form_schema_ext.R") # nolint
