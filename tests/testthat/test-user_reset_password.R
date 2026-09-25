test_that("user_reset_password initiates a reset", {
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
    "ruodk_ur_{format(Sys.time(), '%Y%m%d%H%M%S')}@example.com"
  ) |>
    as.character()

  u <- user_create(email = email, password = "ruodk-test-password")

  withr::defer(
    user_delete(
      actor_id = u$id,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  # Without invalidate the account keeps working
  rs <- user_reset_password(email = email)
  testthat::expect_true(rs$success)
})

test_that("user_reset_password rejects a missing email", {
  testthat::expect_error(
    user_reset_password(
      email = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# usethis::use_r("user_reset_password")  # nolint
