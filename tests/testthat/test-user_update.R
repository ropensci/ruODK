test_that("user_update modifies a User", {
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
    "ruodk_uu_{format(Sys.time(), '%Y%m%d%H%M%S')}@example.com"
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

  uu <- user_update(actor_id = u$id, display_name = "RuODK Test User")
  testthat::expect_equal(uu$display_name, "RuODK Test User")
  testthat::expect_equal(uu$email, email)
})

test_that("user_update needs one field to change", {
  testthat::expect_error(
    user_update(
      actor_id = 1,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "One of display_name or email"
  )
  testthat::expect_error(
    user_update(
      actor_id = NA,
      display_name = "x",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single Actor ID"
  )
})

# usethis::use_r("user_update")  # nolint
