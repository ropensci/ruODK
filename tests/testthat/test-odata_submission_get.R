context("test-odata_submission_get.R")

test_that("odata_submission_get skips download", {
  # A guaranteed empty download directory
  t <- tempdir()
  t %>%
    fs::dir_ls() %>%
    fs::file_delete()

  # Get submissions, do not download attachments
  vcr::use_cassette("test_odata_submission_get0", {
  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    download = FALSE,
    local_dir = t,
    verbose = TRUE
  )})

  # There should be no files in the download dir
  testthat::expect_equal(t %>% fs::dir_ls(), character(0))
})

test_that("odata_submission_get works with one known dataset", {
  # This test downloads files
  skip_on_cran()

  t <- tempdir()
  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = FALSE
  )
  fresh_raw_parsed <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    verbose = TRUE,
    local_dir = t,
    download = TRUE
  )
  fresh_parsed <- fresh_raw %>% odata_submission_rectangle()
  testthat::expect_gte(nrow(fresh_parsed), length(fresh_raw$value))
  testthat::expect_gte(nrow(fresh_parsed), nrow(fresh_raw_parsed))

  testthat::expect_equal(
    class(fresh_raw_parsed$encounter_start_datetime),
    c("POSIXct", "POSIXt")
  )

  local_files <- fresh_raw_parsed %>%
    dplyr::filter(!is.null(location_quadrat_photo)) %>%
    magrittr::extract2("location_quadrat_photo") %>%
    as.character()
  purrr::map(local_files, ~ testthat::expect_true(fs::file_exists(.)))
})


test_that("odata_submission_get skip omits number of results", {
  skip_on_travis()
  skip_on_appveyor()

  vcr::use_cassette("test_odata_submission_get1", {
  fq_svc <- odata_service_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )})

  vcr::use_cassette("test_odata_submission_get2", {
  fresh_parsed <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    download = FALSE,
    table = fq_svc$name[2] # brittle: depends on form used
  )})

  vcr::use_cassette("test_odata_submission_get3", {
  skip_parsed <- odata_submission_get(
    skip = 1,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    download = FALSE,
    table = fq_svc$name[2] # brittle: depends on form used
  )})


  testthat::expect_true(nrow(fresh_parsed) == nrow(skip_parsed) + 1)
})

test_that("odata_submission_get top limits number of results", {
  vcr::use_cassette("test_odata_submission_get4", {
  top_parsed <- odata_submission_get(
    top = 1,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    download = FALSE,
    parse = TRUE
  )})

  # https://github.com/ropensci/ruODK/issues/65
  skip_on_travis()
  skip_on_appveyor()
  testthat::expect_true(nrow(top_parsed) == 1)
})


test_that("odata_submission_get count returns total number or rows", {
  vcr::use_cassette("test_odata_submission_get5", {
  x_raw <- odata_submission_get(
    count = TRUE,
    top = 1,
    wkt = TRUE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = FALSE,
    download = FALSE
  )})
  x_parsed <- x_raw %>% odata_submission_rectangle()


  # https://github.com/ropensci/ruODK/issues/65
  skip_on_travis()
  skip_on_appveyor()

  # Returned: one row
  testthat::expect_true(nrow(x_parsed) == 1)

  # Count: shows all records
  testthat::expect_true("@odata.count" %in% names(x_raw))
  testthat::expect_gte(x_raw$`@odata.count`, nrow(x_parsed))
})

# usethis::edit_file("R/odata_submission_get.R") # nolint
