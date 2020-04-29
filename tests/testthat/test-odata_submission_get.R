context("test-odata_submission_get.R")

test_that("odata_submission_get skips download", {
  # A guaranteed empty download directory
  t <- tempdir()
  t %>%
    fs::dir_ls() %>%
    fs::file_delete()

  # Get submissions, do not download attachments
  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    download = FALSE,
    local_dir = t
  )

  # There should be no files in the download dir
  testthat::expect_equal(t %>% fs::dir_ls(), character(0))
})

test_that("odata_submission_get works with one known dataset", {
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
    local_dir = t
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

  testthat::skip() # https://github.com/dbca-wa/ruODK/issues/65


  fq_svc <- odata_service_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

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
  )

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
  )

  print("odata_submission_get without skip")
  print(fresh_parsed)
  print("odata_submission_get with skip=1 should return one less record")
  print(skip_parsed)
  testthat::expect_true(nrow(fresh_parsed) == nrow(skip_parsed) + 1)
})

test_that("odata_submission_get top limits number of results", {
  testthat::skip() # https://github.com/dbca-wa/ruODK/issues/65

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
  )

  print("odata_submission_get with top=1 should return one record")
  print(top_parsed)

  testthat::expect_true(nrow(top_parsed) == 1)

})


test_that("odata_submission_get count returns total number or rows", {

  testthat::skip() # https://github.com/dbca-wa/ruODK/issues/65


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
  )
  x_parsed <- x_raw %>% odata_submission_rectangle()

  ru_msg_info("odata_submission_get count")
  print(x_raw$`@odata.count`)
  print(x_parsed)

  # Returned: one row
  testthat::expect_true(nrow(x_parsed) == 1)

  # Count: shows all records
  testthat::expect_true("@odata.count" %in% names(x_raw))
  testthat::expect_gte(x_raw$`@odata.count`, nrow(x_parsed))
})


test_that("odata_submission_get parses WKT geopoint", {

  testthat::skip() # https://github.com/dbca-wa/ruODK/issues/65


  df <- odata_submission_get(
    wkt = TRUE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    download = FALSE
  )

  ru_msg_info("WKT test")
  print(df)
  print(names(df))

  testthat::expect_true("location_corner1_latitude" %in% names(df))
  testthat::expect_true("location_corner1_longitude" %in% names(df))
  testthat::expect_true("location_corner1_altitude" %in% names(df))

  testthat::expect_true("perimeter_corner4_latitude" %in% names(df))
  testthat::expect_true("perimeter_corner4_longitude" %in% names(df))
  testthat::expect_true("perimeter_corner4_altitude" %in% names(df))

  print("df$location_corner1_longitude class: ")
  print(class(df$location_corner1_longitude))
  testthat::expect_equal(class(df$location_corner1_longitude), "numeric")
  testthat::expect_equal(class(df$perimeter_corner2_latitude), "numeric")
  testthat::expect_equal(class(df$perimeter_corner3_altitude), "numeric")
})

# Tests code
# usethis::edit_file("R/odata_submission_get.R")
