test_that("submission_export works", {
  # This test downloads files
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # A fresh litterbox
  t <- fs::path(tempdir(), "new_dir")

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

  # Clean up
  fs::dir_ls(t) |> fs::file_delete()
})

test_that("submission_export works with encryption", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  skip_on_ci()

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

  t <- withr::local_tempdir()
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

# nolint start
# Seems it did just that when run from 11 separate GH Actions envs
# test_that(
#   "submission_export with wrong passphphrase does not blow up the server", {
#       skip_if(Sys.getenv("ODKC_TEST_URL")=="", message = "Test server not configured")
#
#     t <- tempdir()
#     fs::dir_ls(t) |> fs::file_delete()
#
#     testthat::expect_error(
#       leeeeroy_jeeenkins <- submission_export(
#         local_dir = t,
#         overwrite = FALSE,
#         pid = Sys.getenv("ODKC_TEST_PID_ENC"),
#         fid = Sys.getenv("ODKC_TEST_FID_ENC"),
#         url = get_test_url(),
#         un = get_test_un(),
#         pw = get_test_pw(),
#         pp = "this is the wrong passphrase",
#         verbose = TRUE
#       )
#     )
# })
# nolint end

test_that("submission_export warns of missing credentials", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  skip_on_ci()

  t <- withr::local_tempdir()

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
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  skip_on_ci()

  # A fresh litterbox
  t <- withr::local_tempdir()

  media_and_repeats <- submission_export(
    local_dir = t,
    overwrite = TRUE,
    verbose = TRUE,
    media = TRUE,
    repeats = TRUE,
    pid = get_test_pid(),
    odkc_version = get_test_odkc_version(),
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
    odkc_version = get_test_odkc_version(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    pp = get_test_pp()
  )

  fsize_no_media_and_repeats <-
    fs::file_info(no_media_and_repeats)$size

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
      odkc_version = get_test_odkc_version(),
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
      odkc_version = get_test_odkc_version(),
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
    odkc_version = "1.0.0",
    # should cause message
    fid = get_test_fid_zip(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    pp = get_test_pp()
  )

  testthat::expect_message(
    submission_export(
      local_dir = t,
      overwrite = FALSE,
      # else "overwrite" message
      verbose = TRUE,
      media = FALSE,
      # won't work on old ODKC
      repeats = TRUE,
      pid = get_test_pid(),
      odkc_version = get_test_odkc_version(),
      # should cause message
      fid = get_test_fid_zip(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      pp = get_test_pp()
    ),
    regexp = "Keeping previous download"
  )

  testthat::expect_message(
    submission_export(
      local_dir = t,
      overwrite = FALSE,
      # else "overwrite" message
      verbose = TRUE,
      media = TRUE,
      repeats = FALSE,
      # won't work on old ODKC
      pid = get_test_pid(),
      odkc_version = "1.0.0",
      # should cause message with odkc_version <= 1.1
      fid = get_test_fid_zip(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      pp = get_test_pp()
    ),
    regexp = "Omitting repeat data"
  )

  fs::dir_ls(t) |> fs::file_delete()
})

test_that("submission_export supports split multiples, group paths, filter", {
  # This test downloads files
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # The I8N choice filter form has select multiples inside a group
  fid <- Sys.getenv("ODKC_TEST_FID_I8N3")
  skip_if(fid == "", message = "I8N test form not configured")

  t <- withr::local_tempdir()
  args <- list(
    local_dir = t,
    overwrite = TRUE,
    verbose = FALSE,
    pid = get_test_pid(),
    odkc_version = get_test_odkc_version(),
    fid = fid,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    pp = get_test_pp()
  )

  read_root_csv <- function(zip) {
    f <- unzip(zip, exdir = t)
    csv <- f[tools::file_ext(f) == "csv"]
    root <- csv[grepl(paste0(fid, "\\.csv$"), csv)]
    readr::read_csv(root[[1]], show_col_types = FALSE, progress = FALSE)
  }

  base <- do.call(submission_export, args)
  testthat::expect_true(fs::is_file(base))
  base_csv <- read_root_csv(base)

  split <- do.call(
    submission_export,
    c(args, list(split_select_multiples = TRUE))
  )
  testthat::expect_true(fs::is_file(split))
  split_csv <- read_root_csv(split)

  testthat::expect_true(
    ncol(split_csv) > ncol(base_csv),
    label = paste0(
      "split_select_multiples=TRUE should add one boolean column ",
      "per select multiple option"
    )
  )

  nogroup <- do.call(
    submission_export,
    c(args, list(group_paths = FALSE))
  )
  testthat::expect_true(fs::is_file(nogroup))
  nogroup_csv <- read_root_csv(nogroup)

  testthat::expect_false(
    identical(names(base_csv), names(nogroup_csv)),
    label = "group_paths=FALSE should strip group prefixes from headers"
  )

  filtered <- do.call(
    submission_export,
    c(args, list(filter = "__system/submissionDate lt 2000-01-01"))
  )
  testthat::expect_true(
    fs::is_file(filtered),
    label = "submission_export with filter should return a file"
  )

  testthat::expect_error(
    do.call(submission_export, c(args, list(filter = 123))),
    regexp = "filter must be a single query string"
  )
})

# usethis::use_r("submission_export") # nolint
