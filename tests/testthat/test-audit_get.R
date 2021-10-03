test_that("audit_get works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

    logs <- audit_get(
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )

    # With search parameters
    logs_pars <- audit_get(
      action = "project.update",
      start = "2019-08-01Z",
      end = "2019-08-31Z",
      limit = 100,
      offset = 0,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )

    logs_part <- audit_get(
      action = "project.update",
      limit = 100,
      offset = 0,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )

  # submission_list returns a tibble
  testthat::expect_equal(class(logs), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_equal(class(logs_pars), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_equal(class(logs_part), c("tbl_df", "tbl", "data.frame"))

  # Submission attributes are the tibble's columns
  cn <- c("actor_id", "action", "actee_id", "details", "logged_at")
  testthat::expect_equal(names(logs), cn)
  testthat::expect_equal(names(logs_pars), cn)
  testthat::expect_equal(names(logs_part), cn)
})

# usethis::use_r("audit_get") # nolint
