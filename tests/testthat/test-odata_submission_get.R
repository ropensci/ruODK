context("test-odata_submission_get.R")

test_that("odata_submission_get skips download", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

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
    local_dir = t,
    verbose = TRUE
  )

  # There should be no files in the download dir
  testthat::expect_equal(t %>% fs::dir_ls(), character(0))
})

test_that("odata_submission_get works with one known dataset", {
  # This test downloads files

  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

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
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  skip_on_travis()
  skip_on_appveyor()

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

  testthat::expect_true(nrow(fresh_parsed) == nrow(skip_parsed) + 1)
})

test_that("odata_submission_get top limits number of results", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

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

  # https://github.com/ropensci/ruODK/issues/65
  skip_on_travis()
  skip_on_appveyor()
  testthat::expect_true(nrow(top_parsed) == 1)
})


test_that("odata_submission_get count returns total number or rows", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

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


  # https://github.com/ropensci/ruODK/issues/65
  skip_on_travis()
  skip_on_appveyor()

  # Returned: one row
  testthat::expect_true(nrow(x_parsed) == 1)

  # Count: shows all records
  testthat::expect_true("@odata.count" %in% names(x_raw))
  testthat::expect_gte(x_raw$`@odata.count`, nrow(x_parsed))
})

test_that("odata_submission_get handles encrypted forms gracefully", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  t <- tempdir()
  fs::dir_ls(t) %>% fs::file_delete()
  se <- odata_submission_get(
    local_dir = t,
    pid = Sys.getenv("ODKC_TEST_PID_ENC"),
    fid = Sys.getenv("ODKC_TEST_FID_ENC"),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    # pp = get_test_pp(),
    verbose = TRUE
  )

  # se is not decrypted
  testthat::expect_s3_class(se, "tbl_df")
  testthat::expect_true("system_status" %in% names(se))
  testthat::expect_equal(
    stringr::str_to_lower(se$system_status[[1]]), # TODO fix NA
    stringr::str_to_lower("NotDecrypted")
  )
})

test_that("odata_submission_get filter works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  x_all <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    download = FALSE
  )
  x_all_filter_null <- odata_submission_get(
    filter = NULL, # the default
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    download = FALSE
  )
  x_all_filter_emptystring <- odata_submission_get(
    filter = "", # the default
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    download = FALSE
  )
  # Some submissions in 2020 - TODO update assumptions
  x_2020 <- odata_submission_get(
    filter = "year(__system/submissionDate) eq 2020", # the default
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    download = FALSE
  )
  # No submissions in 2019 - TODO update assumptions
  x_2019 <- odata_submission_get(
    filter = "year(__system/submissionDate) eq 2019", # the default
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    parse = TRUE,
    download = FALSE
  )

  testthat::expect_equal(
    x_all, x_all_filter_emptystring,
    label = "filter=\"\" should return unfiltered submissions"
  )
  testthat::expect_equal(
    x_all, x_all_filter_null,
    label = "filter=NULL should return unfiltered submissions"
  )

  testthat::expect_equal(
    nrow(x_2020), 0,
    label = "Filter for submissions in year 2020 should return one record"
  )

  if (nrow(x_2019) > 0) {
    ru_msg_warn(glue::glue(
      "Debug: 2019 data has {as.character(nrow(x_2019))} records ",
      "with columns {cat(names(x_2019))}."
    ))
  }
  # nolint start
  # TODO: this works locally but not on GHA.
  testthat::expect_equal(nrow(x_2019), 0,
    label = "Filter for submissions in year 2019 should return no records"
  )
  # nolint end
})

test_that("odata_submission_get expand works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  x_expanded <- odata_submission_get(
    expand = TRUE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    download = FALSE,
    parse = TRUE
  )

  x <- odata_submission_get(
    expand = FALSE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version(),
    download = FALSE,
    parse = TRUE
  )

  purrr::map(
    names(x),
    ~ testthat::expect_true(
      . %in% names(x_expanded),
      label = glue::glue(
        "Column {.} from unexpanded submissions",
        " missing from expanded submissions"
      )
    )
  )
})

# usethis::use_r("odata_submission_get") # nolint
