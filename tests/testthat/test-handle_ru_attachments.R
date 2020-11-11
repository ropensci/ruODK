test_that("handle_ru_attachments downloads files", {
  # This test downloads files
  skip_on_cran()

  data("fq_raw")
  data("fq_form_schema")

  t <- tempdir()
  fs::dir_ls(t) %>% fs::file_delete()

  fq_with_att <- fq_raw %>%
    ruODK::odata_submission_rectangle() %>%
    ruODK::handle_ru_attachments(
      form_schema = fq_form_schema,
      local_dir = t,
      pid = ruODK::get_test_pid(),
      fid = ruODK::get_test_fid(),
      url = ruODK::get_test_url(),
      un = ruODK::get_test_un(),
      pw = ruODK::get_test_pw(),
      verbose = ruODK::get_ru_verbose()
    )

  # There should be files in local_dir
  testthat::expect_true(fs::dir_ls(t) %>% length() > 0)
})

# usethis::use_r("handle_ru_attachments") # nolint
