test_that("app_user_delete deletes an App User", {
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
      "ruodk_ad_{format(Sys.time(), '%Y%m%d%H%M%S')}"
    ) |>
      as.character()
  )

  dl <- app_user_delete(pid = get_test_pid(), id = au$id)
  testthat::expect_true(dl$success)

  listed <- app_user_list(pid = get_test_pid())
  listed_ids <- if ("id" %in% names(listed)) listed$id else integer(0)
  testthat::expect_false(au$id %in% listed_ids)
})

test_that("app_user_delete rejects a missing ID", {
  testthat::expect_error(
    app_user_delete(
      pid = 1,
      id = NA,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single App User ID"
  )
})

# usethis::use_r("app_user_delete")  # nolint
