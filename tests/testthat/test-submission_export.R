test_that("submission_export works", {

  # A fresh litterbox
  t <- tempdir()

  # High expectatios
  fid <- Sys.getenv("ODKC_TEST_FID")
  pth <- fs::path(t, glue::glue("{fid}.zip"))
  fid_csv <- fs::path(t, glue::glue("{fid}.csv"))
  msg_dl <- glue::glue("Downloading submissions to: {pth}\n")
  msg_keep <- glue::glue("Keeping previous download: {pth}\n")
  msg_chuck <- glue::glue("Overwriting previous download: {pth}\n")

  # Once you drink Tequila, you're feeling really gööd
  testthat::expect_message(
    se <- submission_export(
      Sys.getenv("ODKC_TEST_PID"),
      Sys.getenv("ODKC_TEST_FID"),
      local_dir = t,
      overwrite = FALSE,
      verbose = TRUE,
      url = Sys.getenv("ODKC_TEST_URL"),
      un = Sys.getenv("ODKC_TEST_UN"),
      pw = Sys.getenv("ODKC_TEST_PW")
    ),
    msg_dl
  )
  dl1 <- fs::file_info(se)$modification_time

  # Twice you drink Tequila, you're getting in ze mööd
  testthat::expect_message(
    se <- submission_export(
      Sys.getenv("ODKC_TEST_PID"),
      Sys.getenv("ODKC_TEST_FID"),
      local_dir = t,
      overwrite = FALSE,
      verbose = TRUE,
      url = Sys.getenv("ODKC_TEST_URL"),
      un = Sys.getenv("ODKC_TEST_UN"),
      pw = Sys.getenv("ODKC_TEST_PW")
    ),
    msg_keep
  )

  # Repeated download with overwrite = FALSE retains file
  dl2 <- fs::file_info(se)$modification_time
  testthat::expect_true(dl1 == dl2)

  # Three times Tequila, your cheeks gonna glööw
  testthat::expect_message(
    se <- submission_export(
      Sys.getenv("ODKC_TEST_PID"),
      Sys.getenv("ODKC_TEST_FID"),
      local_dir = t,
      overwrite = TRUE,
      verbose = TRUE,
      url = Sys.getenv("ODKC_TEST_URL"),
      un = Sys.getenv("ODKC_TEST_UN"),
      pw = Sys.getenv("ODKC_TEST_PW")
    ),
    msg_chuck
  )

  # Repeated download with overwrite = TRUE replaces file
  dl3 <- fs::file_info(se)$modification_time
  testthat::expect_false(dl1 == dl3)

  # Four times Tequila, öh öh öh
  # \url{https://www.youtube.com/watch?v=cWd5Uiyx5zg}
  testthat::expect_message(
    se <- submission_export(
      Sys.getenv("ODKC_TEST_PID"),
      Sys.getenv("ODKC_TEST_FID"),
      local_dir = t,
      overwrite = FALSE,
      verbose = TRUE,
      url = Sys.getenv("ODKC_TEST_URL"),
      un = Sys.getenv("ODKC_TEST_UN"),
      pw = Sys.getenv("ODKC_TEST_PW")
    ),
    msg_keep
  )

  # Repeated download with overwrite = FALSE retains file
  dl4 <- fs::file_info(se)$modification_time
  testthat::expect_true(dl4 == dl3)

  # Comb through the litterbox
  f <- unzip(se, exdir = t)

  # Find the payload
  testthat::expect_true(fid_csv %in% fs::dir_ls(t))

  # Chuck the litter out
  fs::dir_delete(t)
})
