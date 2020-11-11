test_that("form_list works", {
  vcr::use_cassette("test_form_list0", {
    fl <- form_list(
      get_test_pid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  })
  testthat::expect_equal(class(fl), c("tbl_df", "tbl", "data.frame"))
  cn <- c(
    "name", "fid", "version", "state", "submissions", "created_at",
    "created_by_id", "created_by", "updated_at", "last_submission", "hash"
  )
  testthat::expect_equal(names(fl), cn)

  # Testing #86 form_list should work with draft forms present.
  # The above call to form_list worked so we test here that
  # the test forms contain a draft form.
  # Draft forms have a NA hash and version.
  fl %>%
    dplyr::filter(
      is.na(version) & is.na(hash)
    ) %>%
    nrow() %>%
    testthat::expect_gt(0)
})

# usethis::use_r("form_list") # nolint
