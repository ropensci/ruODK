test_that("entitylist_download works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  skip_on_ci()

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

  # The file was downloaded
  testthat::expect_true(
    fs::file_exists(ds1)
  )

  # Download to same location, do not overwrite: emit message, return file path
  testthat::expect_message(
    ds2 <- entitylist_download(
      did = ds$name[1],
      local_dir = tempd,
      overwrite = FALSE
    )
  )

  # The returned file path is the same as from the first download
  testthat::expect_equal(ds1, ds2)
})


test_that("entitylist_download warns if did is missing", {
  testthat::expect_error(
    entitylist_download()
  )
})


# usethis::use_r("entitylist_download")  # nolint
