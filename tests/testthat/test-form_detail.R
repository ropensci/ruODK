test_that("form_detail works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # The test project has a list of forms
  fl <- form_list(
    get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  # The first form in the test project
  f <- form_detail(
    get_test_pid(),
    fl$fid[[1]],
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  # form_detail returns exactly one row
  testthat::expect_true(nrow(f) == 1)

  # Columns: name, xmlFormId, and more
  testthat::expect_true("name" %in% names(f))
  testthat::expect_true("fid" %in% names(f))
  cn <- c(
    "name", "fid", "version", "state", "submissions", "created_at",
    "created_by_id", "created_by", "updated_at", "published_at",
    "last_submission", "hash"
  )
  testthat::expect_equal(names(f), cn)
})

# usethis::use_r("form_detail") # nolint
