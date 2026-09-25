test_that("user_delete deletes a User", {
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

  email <- glue::glue(
    "ruodk_ud_{format(Sys.time(), '%Y%m%d%H%M%S')}@example.com"
  ) |>
    as.character()

  u <- user_create(email = email, password = "ruodk-test-password")

  dl <- user_delete(actor_id = u$id)
  testthat::expect_true(dl$success)
})

test_that("user_delete rejects a missing ID", {
  testthat::expect_error(
    user_delete(
      actor_id = NA,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single Actor ID"
  )
  testthat::expect_error(
    user_delete(
      actor_id = 1,
      url = "",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("user_delete")  # nolint
