test_that("user_create creates and deletes a User", {
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
    "ruodk_uc_{format(Sys.time(), '%Y%m%d%H%M%S')}@example.com"
  ) |>
    as.character()

  u <- user_create(email = email, password = "ruodk-test-password")
  testthat::expect_equal(nrow(u), 1)
  testthat::expect_equal(u$email, email)

  withr::defer(
    user_delete(
      actor_id = u$id,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  ul <- user_list()
  testthat::expect_true(u$id %in% ul$id)
})

test_that("user_create rejects a missing email", {
  testthat::expect_error(
    user_create(
      email = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
  testthat::expect_error(
    user_create(
      email = "a@example.com",
      url = "",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("user_create")  # nolint
