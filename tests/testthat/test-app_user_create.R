test_that("app_user_create creates an App User", {
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

  au <- app_user_create(
    pid = get_test_pid(),
    display_name = glue::glue(
      "ruodk_au_{format(Sys.time(), '%Y%m%d%H%M%S')}"
    ) |>
      as.character()
  )
  testthat::expect_equal(nrow(au), 1)
  # The token is only returned at creation time
  testthat::expect_true(!is.na(au$token) && nzchar(au$token))

  withr::defer(
    app_user_delete(
      pid = get_test_pid(),
      id = au$id,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  listed <- app_user_list(pid = get_test_pid())
  testthat::expect_true(au$id %in% listed$id)
})

test_that("app_user_create rejects a missing name", {
  testthat::expect_error(
    app_user_create(
      pid = 1,
      display_name = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# usethis::use_r("app_user_create")  # nolint
