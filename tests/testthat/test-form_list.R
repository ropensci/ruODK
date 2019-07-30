test_that("form_list works", {
  fl <- form_list(
    Sys.getenv("ODKC_TEST_PID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_equal(class(fl), c("tbl_df", "tbl", "data.frame"))
  cn <- c(
    "name", "fid", "version", "state", "submissions", "created_at",
    "created_by_id", "created_by", "updated_at", "last_submission", "hash",
    "xml"
  )
  testthat::expect_equal(names(fl), cn)
})
