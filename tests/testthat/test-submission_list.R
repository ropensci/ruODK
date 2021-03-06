test_that("submission_list works", {
  vcr::use_cassette("test_submission_list0", {
    sl <- submission_list(
      get_test_pid(),
      get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )

    fl <- form_list(
      get_test_pid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })
  # submission_list returns a tibble
  testthat::expect_equal(class(sl), c("tbl_df", "tbl", "data.frame"))

  # Submission attributes are the tibble's columns
  cn <- c(
    "instance_id",
    "submitter_id",
    "submitter_type",
    "submitter_display_name",
    "submitter_created_at",
    "device_id",
    "created_at"
  )
  testthat::expect_equal(names(sl), cn)
  purrr::map(
    cn,
    ~ testthat::expect_true(
      . %in% names(sl),
      label = glue::glue("Column {.} missing from submission_list")
    )
  )

  # Number of submissions (rows) is same as advertised in form_list
  form_list_nsub <- fl %>%
    dplyr::filter(fid == get_test_fid()) %>%
    magrittr::extract2("submissions") %>%
    as.numeric()
  testthat::expect_equal(nrow(sl), form_list_nsub)
})

# usethis::use_r("submission_list") # nolint
