test_that("assignment_list lists server-wide Assignments", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  al <- assignment_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(class(al), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true(all(c("actor_id", "role_id") %in% names(al)))
})

test_that("assignment_list rejects missing input", {
  testthat::expect_error(
    assignment_list(url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("assignment_list")  # nolint
