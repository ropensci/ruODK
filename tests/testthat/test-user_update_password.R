test_that("user_update_password changes a password", {
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
    "ruodk_up_{format(Sys.time(), '%Y%m%d%H%M%S')}@example.com"
  ) |>
    as.character()

  u <- user_create(email = email, password = "ruodk-old-password")

  withr::defer(
    user_delete(
      actor_id = u$id,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  up <- user_update_password(
    actor_id = u$id,
    old_password = "ruodk-old-password",
    new_password = "ruodk-new-password"
  )
  testthat::expect_true(up$success)

  # The new password authenticates
  me <- user_detail(
    actor_id = "current",
    url = get_test_url(),
    un = email,
    pw = "ruodk-new-password"
  )
  testthat::expect_equal(me$email, email)
})

test_that("user_update_password rejects missing passwords", {
  testthat::expect_error(
    user_update_password(
      actor_id = 1,
      old_password = "",
      new_password = "new",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# usethis::use_r("user_update_password")  # nolint
