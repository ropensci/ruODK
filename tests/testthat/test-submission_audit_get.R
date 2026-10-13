test_that("submission_audit_get downloads server audit logs", {
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

  sl <- submission_list(fid = get_test_fid())
  iid <- sl$instance_id[[1]]

  one <- get_one_submission_audit(iid = iid, fid = get_test_fid())
  testthat::expect_true(is.list(one))
  testthat::expect_gt(length(one), 0)

  all <- submission_audit_get(iid = sl$instance_id, fid = get_test_fid())
  testthat::expect_equal(length(all), nrow(sl))
})

test_that("submission_audit_get rejects missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    get_one_submission_audit(
      iid = "",
      pid = 1,
      fid = "f",
      url = url,
      un = un,
      pw = pw
    ),
    "Missing ODK Central"
  )
  testthat::expect_error(
    submission_audit_get(
      iid = "",
      pid = 1,
      fid = "f",
      url = url,
      un = un,
      pw = pw
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_audit_get")  # nolint
