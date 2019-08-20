test_that("audit_get works", {
  logs <- audit_get(
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )

  # With search parameters
  logs_pars <- audit_get(
    action = "project.update",
    start = "2019-08-01Z",
    end = "2019-08-31Z",
    limit = 100,
    offset = 0,
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )

  logs_part <- audit_get(
    action = "project.update",
    limit = 100,
    offset = 0,
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
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

# Tests
# usethis::edit_file("R/audit_get.R")
