test_that("attachment_link works", {

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
    pw = get_test_pw()
  )

  # Comb through the litterbox
  f <- unzip(se, exdir = t)

  # Find the payload
  testthat::expect_true(fid_csv %in% fs::dir_ls(t))
  testthat::expect_true(fs::file_exists(fid_csv))

  # Test attachment_link - this saves another download of the ZIP file
  # Tests usethis::edit_file("R/attachment_link.R")
  suppressWarnings(
    data_quadrat_csv <- fid_csv %>%
      readr::read_csv(na = c("", "NA", "na")) %>%
      janitor::clean_names(.) %>%
      attachment_link(.) %>%
      ru_datetime()
  )

  # Test that filepath of attachment exists
  for (i in seq_len(nrow(data_quadrat_csv))) {
    testthat::expect_true(
      fs::path(t, data_quadrat_csv[i, ]$location_quadrat_photo) %>%
        fs::file_exists()
    )
  }
})
