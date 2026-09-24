test_that("form_assignment_list summarizes Form Assignments", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  al <- form_assignment_list(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(class(al), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true(
    all(c("actor_id", "xml_form_id", "role_id") %in% names(al))
  )
})

test_that("form_assignment_list rejects missing input", {
  testthat::expect_error(
    form_assignment_list(pid = 1, url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_assignment_list")  # nolint
