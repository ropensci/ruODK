test_that("submission_export works", {

  # A fresh litterbox
  t <- tempdir()

  # High expectations
  fid <- "build_Spotlighting-0-6_1558333698" # small and without attachments
  pth <- fs::path(t, glue::glue("{fid}.zip"))
  fid_csv <- fs::path(t, glue::glue("{fid}.csv"))
  msg_dl <- glue::glue("Downloading submissions to: {pth}\n")
  msg_keep <- glue::glue("Keeping previous download: {pth}\n")
  msg_chuck <- glue::glue("Overwriting previous download: {pth}\n")

  # Once you drink Tequila, you're feeling really good
  testthat::expect_message(
    se <- submission_export(
      local_dir = t,
      overwrite = FALSE,
      verbose = TRUE,
      pid = get_test_pid(),
      fid = fid,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    ),
    msg_dl
  )
  dl1 <- fs::file_info(se)$modification_time

  # Twice you drink Tequila, you're getting in ze mood
  testthat::expect_message(
    se <- submission_export(
      local_dir = t,
      overwrite = FALSE,
      verbose = TRUE,
      pid = get_test_pid(),
      fid = fid,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    ),
    msg_keep
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
      fid = fid,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    ),
    msg_chuck
  )

  # Repeated download with overwrite = TRUE replaces file
  dl3 <- fs::file_info(se)$modification_time
  testthat::expect_false(dl1 == dl3)

  # Four Tequila, oh oh oh
  # \url{https://www.youtube.com/watch?v=cWd5Uiyx5zg}
  testthat::expect_message(
    se <- submission_export(
      local_dir = t,
      overwrite = FALSE,
      verbose = TRUE,
      pid = get_test_pid(),
      fid = fid,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
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

})

# Tests code
# usethis::edit_file("R/submission_export.R")
