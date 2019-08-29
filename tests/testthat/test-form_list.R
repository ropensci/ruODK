test_that("form_list works", {
  fl <- form_list(
    get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(class(fl), c("tbl_df", "tbl", "data.frame"))
  cn <- c(
    "name", "fid", "version", "state", "submissions", "created_at",
    "created_by_id", "created_by", "updated_at", "last_submission", "hash"
  )
  testthat::expect_equal(names(fl), cn)
})

# Tests code
# usethis::edit_file("R/form_list.R")
