context("test-odata_submission_get.R")

test_that("odata_submission_get works with one known dataset", {
  t <- tempdir()
  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    parse = FALSE
  )
  fresh_raw_parsed <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    parse = TRUE,
    verbose = TRUE,
    local_dir = t
  )
  fresh_parsed <- fresh_raw %>% odata_submission_parse()
  testthat::expect_gte(nrow(fresh_parsed), length(fresh_raw$value))
  testthat::expect_gte(nrow(fresh_parsed), nrow(fresh_raw_parsed))

  testthat::expect_equal(
    class(fresh_raw_parsed$encounter_start_datetime),
    c("POSIXct", "POSIXt")
  )

  local_files <- fresh_raw_parsed %>%
    dplyr::filter(!is.null(quadrat_photo)) %>%
    magrittr::extract2("quadrat_photo") %>%
    as.character()
  purrr::map(local_files, ~ testthat::expect_true(fs::file_exists(.)))
})


test_that("odata_submission_get skip omits number of results", {
  fq_svc <- odata_service_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    parse = FALSE,
    table = fq_svc$name[2] # brittle: depends on form used
  )
  fresh_parsed <- fresh_raw %>% odata_submission_parse()

  skip_raw <- odata_submission_get(
    skip = 1,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    parse = FALSE,
    table = fq_svc$name[2] # brittle: depends on form used
  )
  skip_parsed <- skip_raw %>% odata_submission_parse()

  testthat::expect_true(nrow(fresh_parsed) == nrow(skip_parsed) + 1)
})

test_that("odata_submission_get top limits number of results", {
  top_raw <- odata_submission_get(
    top = 1,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    parse = FALSE
  )
  top_parsed <- top_raw %>% odata_submission_parse()

  testthat::expect_true(nrow(top_parsed) == 1)
})


test_that("odata_submission_get count returns total number or rows", {
  x_raw <- odata_submission_get(
    count = TRUE,
    top = 1,
    wkt = TRUE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    parse = FALSE
  )
  x_parsed <- x_raw %>% odata_submission_parse()

  # Returned: one row
  testthat::expect_true(nrow(x_parsed) == 1)

  # Count: shows all records
  testthat::expect_true("@odata.count" %in% names(x_raw))
  testthat::expect_gte(x_raw$`@odata.count`, nrow(x_parsed))
})


test_that("odata_submission_get parses WKT geopoint", {
  df <- odata_submission_get(
    wkt = TRUE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    parse = TRUE,
    verbose = TRUE
  )

  testthat::expect_true("corner1_latitude" %in% names(df))
  testthat::expect_true("corner1_longitude" %in% names(df))
  testthat::expect_true("corner1_altitude" %in% names(df))

  testthat::expect_true("corner4_latitude" %in% names(df))
  testthat::expect_true("corner4_longitude" %in% names(df))
  testthat::expect_true("corner4_altitude" %in% names(df))

  testthat::expect_true(is.numeric(df$corner1_longitude))
  testthat::expect_true(is.numeric(df$corner2_latitude))
  testthat::expect_true(is.numeric(df$corner3_altitude))
})

# Tests code
# usethis::edit_file("R/odata_submission_get.R")
