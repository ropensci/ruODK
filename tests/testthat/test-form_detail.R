test_that("form_detail works", {

  # The test project has a list of forms
  fl <- form_list(
    Sys.getenv("ODKC_TEST_PID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )

  # The first form in the test project
  f <- form_detail(
    Sys.getenv("ODKC_TEST_PID"),
    fl$fid[[1]],
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )

  # form_detail returns exactly one row
  testthat::expect_true(nrow(f) == 1)

  # Columns: name, xmlFormId, and more
  testthat::expect_true("name" %in% names(f))
  testthat::expect_true("fid" %in% names(f))
  cn <- c(
    "name", "fid", "version", "state", "submissions", "created_at",
    "created_by_id", "created_by", "updated_at", "last_submission",
    "hash", "xml"
  )
  testthat::expect_equal(names(f), cn)
})
