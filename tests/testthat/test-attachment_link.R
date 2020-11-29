test_that("submission_export works", {
  # This test downloads files
  skip_on_cran()

  # A fresh litterbox
  t <- tempdir()
  fid <- get_test_fid_att() # Form with one submission

  fid_csv <- fs::path(t, glue::glue("{fid}.csv"))

  # Download submissions of a form with media attachments
  se <- submission_export(
    local_dir = t,
    overwrite = TRUE,
    verbose = TRUE,
    pid = get_test_pid(),
    fid = fid,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    pp = get_test_pp()
  )

  fs <- form_schema(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    pid = get_test_pid(),
    fid = fid,
    odkc_version = get_test_odkc_version()
  )

  # Comb through the litterbox
  f <- unzip(se, exdir = t)

  # Find the payload
  testthat::expect_true(fid_csv %in% fs::dir_ls(t))
  testthat::expect_true(fs::file_exists(fid_csv))

  suppressWarnings(
    data_quadrat_csv <- fid_csv %>%
      readr::read_csv(na = c("", "NA", "na")) %>%
      janitor::clean_names(.) %>%
      handle_ru_datetimes(fs) %>%
      # handle_ru_geopoints(fs) %>% # no geopoints
      attachment_link(fs)
  )

  # Test that filepath of attachment exists
  for (i in seq_len(nrow(data_quadrat_csv))) {
    testthat::expect_true(
      fs::path(t, data_quadrat_csv[i, ]$location_quadrat_photo) %>%
        fs::file_exists()
    )
  }
})
