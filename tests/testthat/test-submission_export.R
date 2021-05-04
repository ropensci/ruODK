test_that("submission_export works", {
  # This test downloads files
  skip_on_cran()

  # A fresh litterbox
  t <- tempdir()
  fs::dir_ls(t) %>% fs::file_delete()

  # High expectations
  pth <- fs::path(
    t,
    glue::glue("{URLencode(get_test_fid_zip(), reserved = TRUE)}.zip")
  )
  fid_csv <- fs::path(
    t,
    glue::glue("{URLencode(get_test_fid_zip(), reserved = TRUE)}.csv")
  )

  # Once you drink Tequila, you're feeling really good
  testthat::expect_message(
    se <- submission_export(
      local_dir = t,
      overwrite = FALSE,
      verbose = TRUE,
      pid = get_test_pid(),
      fid = get_test_fid_zip(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      pp = get_test_pp()
    ),
    regexp = "Downloading submissions"
  )
  dl1 <- fs::file_info(se)$modification_time

  # Twice you drink Tequila, you're getting in ze mood
  testthat::expect_message(
    se <- submission_export(
      local_dir = t,
      overwrite = FALSE,
      verbose = TRUE,
      pid = get_test_pid(),
      fid = get_test_fid_zip(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      pp = get_test_pp()
    ),
    regexp = "Keeping previous download"
  )

  # Repeated download with overwrite = FALSE retains file
  dl2 <- fs::file_info(se)$modification_time
  testthat::expect_true(dl1 == dl2)

  # Three times Tequila, your cheeks gonna glow
  testthat::expect_message(
    se <- submission_export(
      local_dir = t,
      overwrite = TRUE,
      verbose = TRUE,
      pid = get_test_pid(),
      fid = get_test_fid_zip(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      pp = get_test_pp()
    ),
    regexp = "Overwriting previous download"
  )

  # Repeated download with overwrite = TRUE replaces file
  dl3 <- fs::file_info(se)$modification_time
  testthat::expect_false(dl1 == dl3)

  # Four Tequila, oh oh oh
  # https://www.youtube.com/watch?v=cWd5Uiyx5zg
  testthat::expect_message(
    se <- submission_export(
      local_dir = t,
      overwrite = FALSE,
      verbose = TRUE,
      pid = get_test_pid(),
      fid = get_test_fid_zip(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      pp = get_test_pp()
    ),
    regexp = "Keeping previous download"
  )

  # Repeated download with overwrite = FALSE retains file
  dl4 <- fs::file_info(se)$modification_time
  testthat::expect_true(dl4 == dl3)

  # Comb through the litterbox
  f <- unzip(se, exdir = t)

  # Find the payload
  testthat::expect_true(fid_csv %in% fs::dir_ls(t))
})

test_that("submission_export works with encryption", {
  skip_on_cran()

  # nolint start
  # # This is needed to run the tests for this file only
  # if (is.null(vcr::vcr_configuration()$write_disk_path)) {
  #   vcr::vcr_configure(write_disk_path = "../files")
  # }
  #
  # wdp <- vcr::vcr_configuration()$write_disk_path
  # testthat::expect_true(
  #   fs::is_dir(wdp),
  #   label = glue::glue("VCR write_disk_path must exist: {wdp}")
  # )
  # nolint end

  t <- tempdir()
  fs::dir_ls(t) %>% fs::file_delete()
  # vcr::use_cassette("test_submission_export0", {
  se <- submission_export(
    local_dir = t,
    overwrite = FALSE,
    pid = Sys.getenv("ODKC_TEST_PID_ENC"),
    fid = Sys.getenv("ODKC_TEST_FID_ENC"),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    pp = get_test_pp(),
    verbose = TRUE
  )
  # })

  testthat::expect_true(
    fs::is_file(se),
    label = glue::glue("Submission ZIP must be a file: {se}")
  )
})

test_that("submission_export warns of missing credentials", {
  t <- tempdir()
  fs::dir_ls(t) %>% fs::file_delete()

  testthat::expect_error(
    se <- submission_export(
      pid = "",
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      overwrite = FALSE,
      local_dir = t,
      verbose = TRUE
    )
  )

  testthat::expect_error(
    se <- submission_export(
      pid = get_test_pid(),
      fid = "",
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      overwrite = FALSE,
      local_dir = t,
      pp = get_test_pp(),
      verbose = TRUE
    )
  )

  testthat::expect_error(
    se <- submission_export(
      pid = Sys.getenv("ODKC_TEST_PID_ENC"),
      fid = Sys.getenv("ODKC_TEST_FID_ENC"),
      url = "",
      un = get_test_un(),
      pw = get_test_pw(),
      overwrite = FALSE,
      local_dir = t,
      pp = get_test_pp(),
      verbose = TRUE
    )
  )

  testthat::expect_error(
    se <- submission_export(
      pid = Sys.getenv("ODKC_TEST_PID_ENC"),
      fid = Sys.getenv("ODKC_TEST_FID_ENC"),
      url = get_test_url(),
      un = "",
      pw = get_test_pw(),
      overwrite = FALSE,
      local_dir = t,
      pp = get_test_pp(),
      verbose = TRUE
    )
  )

  testthat::expect_error(
    se <- submission_export(
      pid = Sys.getenv("ODKC_TEST_PID_ENC"),
      fid = Sys.getenv("ODKC_TEST_FID_ENC"),
      url = get_test_url(),
      un = get_test_un(),
      pw = "",
      overwrite = FALSE,
      local_dir = t,
      pp = get_test_pp(),
      verbose = TRUE
    )
  )
})

test_that("submission_export excludes media", {
  # This test downloads files
  skip_on_cran()

  # A fresh litterbox
  t <- tempdir()
  fs::dir_ls(t) %>% fs::file_delete()

  media_and_repeats <- submission_export(
    local_dir = t,
    overwrite = TRUE,
    verbose = TRUE,
    media = TRUE,
    repeats = TRUE,
    pid = get_test_pid(),
    odkc_version = 1.1,
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    pp = get_test_pp()
  )

  fsize_media_and_repeats <- fs::file_info(media_and_repeats)$size

  no_media_and_repeats <- submission_export(
    local_dir = t,
    overwrite = TRUE,
    verbose = TRUE,
    media = FALSE,
    repeats = TRUE,
    pid = get_test_pid(),
    odkc_version = 1.1,
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    pp = get_test_pp()
  )

  fsize_no_media_and_repeats <- fs::file_info(no_media_and_repeats)$size

  testthat::expect_true(
    fsize_media_and_repeats > fsize_no_media_and_repeats,
    label = "submission_export omitting media should result in smaller ZIP"
  )

  suppressWarnings(
    no_media_no_repeats <- submission_export(
      local_dir = t,
      overwrite = TRUE,
      verbose = TRUE,
      media = FALSE,
      repeats = FALSE,
      pid = get_test_pid(),
      odkc_version = 1.1,
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      pp = get_test_pp()
    )
  )

  testthat::expect_true(
    tools::file_ext(no_media_no_repeats) == "csv",
    label = "submission_export(repeats=FALSE) should return a CSV"
  )

  suppressWarnings(
    media_no_repeats <- submission_export(
      local_dir = t,
      overwrite = TRUE,
      verbose = TRUE,
      media = TRUE,
      repeats = FALSE,
      pid = get_test_pid(),
      odkc_version = 1.1,
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      pp = get_test_pp()
    )
  )

  testthat::expect_true(
    tools::file_ext(media_no_repeats) == "csv",
    label = "submission_export(repeats=FALSE, media=TRUE) should return a CSV"
  )

  wrong_version_no_warning <- submission_export(
    local_dir = t,
    overwrite = TRUE,
    verbose = TRUE,
    media = TRUE,
    repeats = TRUE,
    pid = get_test_pid(),
    odkc_version = 1.0, # should cause message
    fid = get_test_fid_zip(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    pp = get_test_pp()
  )

  testthat::expect_message(
    submission_export(
      local_dir = t,
      overwrite = FALSE, # else "overwrite" message
      verbose = TRUE,
      media = FALSE, # won't work on old ODKC
      repeats = TRUE,
      pid = get_test_pid(),
      odkc_version = 1.0, # should cause message
      fid = get_test_fid_zip(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      pp = get_test_pp()
    ),
    regexp = "Omitting media attachments"
  )

  testthat::expect_message(
    submission_export(
      local_dir = t,
      overwrite = FALSE, # else "overwrite" message
      verbose = TRUE,
      media = TRUE,
      repeats = FALSE, # won't work on old ODKC
      pid = get_test_pid(),
      odkc_version = 1.0, # should cause message
      fid = get_test_fid_zip(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      pp = get_test_pp()
    ),
    regexp = "Omitting repeat data"
  )

  fs::dir_ls(t) %>% fs::file_delete()
})

# usethis::use_r("submission_export") # nolint
