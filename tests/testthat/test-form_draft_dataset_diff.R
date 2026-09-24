test_that("form_draft_dataset_diff reflects pending changes", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  form_draft_create(fid = "report_problem")

  withr::defer(
    form_draft_delete(
      fid = "report_problem",
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  dd <- form_draft_dataset_diff(fid = "report_problem")
  testthat::expect_true(length(dd) >= 1)
  testthat::expect_equal(dd[[1]]$name, "problems")
})

test_that("form_draft_dataset_diff rejects missing input", {
  testthat::expect_error(
    form_draft_dataset_diff(fid = "f", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_draft_dataset_diff")  # nolint
