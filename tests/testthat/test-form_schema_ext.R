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

# usethis::edit_file("R/form_schema_ext.R") # nolint
