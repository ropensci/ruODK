test_that("entitylist_download works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # skip_on_ci()

  tempd <- fs::path(tempdir(), "new_dir")

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  ds <- entitylist_list()

  ds1 <- entitylist_download(did = ds$name[1], local_dir = tempd)

  # Format:
  # list(
  #   entities =  httr::content(res, encoding = "utf-8"),
  #   etag = res$headers$etag,
  #   downloaded_to = pth,
  #   downloaded_on = isodt_to_local(res$date, orders = orders, tz = tz)
  # )

  # The Entity List is also returned as a tibble
  testthat::expect_s3_class(ds1$entities, "tbl_df")

  # An ETag was returned
  testthat::expect_is(ds1$etag, "character")

  # The CSV file was downloaded
  testthat::expect_true(fs::file_exists(ds1$downloaded_to))

  # The timestamp is included
  testthat::expect_s3_class(ds1$downloaded_on, "POSIXct")

  # Download to same location, do not overwrite: error
  # Error: Path exists and overwrite is FALSE
  testthat::expect_error(
    entitylist_download(
      did = ds$name[1],
      local_dir = tempd,
      overwrite = FALSE
    )
  )

  ds2 <- entitylist_download(
    did = ds$name[1],
    local_dir = tempd,
    overwrite = TRUE
  )

  # The returned file path is the same as from the first download
  testthat::expect_equal(ds1$downloaded_to, ds2$downloaded_to)

  # Clean up
  fs::dir_ls(tempd) %>% fs::file_delete()
})


test_that("entitylist_download etag works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # skip_on_ci()

  tempd <- tempdir()
  fs::dir_ls(tempd) %>% fs::file_delete()

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  ds <- entitylist_list()

  ds1 <- entitylist_download(did = ds$name[1], local_dir = tempd)

  # Download only entities added since last download (ds1) = None
  ds2 <- entitylist_download(
    did = ds$name[1],
    local_dir = tempd,
    overwrite = TRUE,
    etag = ds1$etag
  )

  testthat::expect_equal(ds2$http_status, 304)
  testthat::expect_equal(ds2$entities, NULL)
})

test_that("entitylist_download filter works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # skip_on_ci()

  tempd <- tempdir()
  fs::dir_ls(tempd) %>% fs::file_delete()

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  ds <- entitylist_list()

  ds1 <- entitylist_download(did = ds$name[1], local_dir = tempd)

  newest_entity_date <- as.Date(max(ds1$entities$`__createdAt`))

  # Should return all entities (created before or on date of latest entity)
  # Currently returns HTTP 501
  # ds2 <- entitylist_download(
  #      did = ds$name[1],
  #      filter=glue::glue("__createdAt le {newest_entity_date}")
  #   )

  # testthat::expect_equal(ds2$http_status, 200)
  # testthat::expect_true(nrow(ds2$entities))

  # Resolve warning about empty test
  testthat::expect_true(TRUE)
})

test_that("entitylist_download errors if did is missing", {
  testthat::expect_error(
    entitylist_download()
  )
})

test_that("entitylist_download warns if odkc_version too low", {
  tempd <- tempdir()
  fs::dir_ls(tempd) %>% fs::file_delete()

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  ds <- entitylist_list()

  testthat::expect_warning(
    entitylist_download(
      did = ds$name[1],
      local_dir = tempd,
      odkc_version = "1.5.3"
    )
  )
})


# usethis::use_r("entitylist_download")  # nolint
