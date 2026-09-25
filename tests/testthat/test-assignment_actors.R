test_that("assignment_actors lists server admins", {
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

  aa <- assignment_actors(role_id = "admin")
  testthat::expect_true(nrow(aa) > 0)
})

test_that("assignment_actors is version gated", {
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

  testthat::expect_warning(
    assignment_actors(role_id = "admin", odkc_version = "0.4"),
    "supported from v0.5"
  )
})

test_that("assignment_actors rejects a missing role", {
  testthat::expect_error(
    assignment_actors(
      role_id = NA,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single Role ID"
  )
})

# usethis::use_r("assignment_actors")  # nolint
