test_that("assignment grant/revoke roundtrip works", {
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
    "ruodk_ag_{format(Sys.time(), '%Y%m%d%H%M%S')}@example.com"
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

  gr <- assignment_grant(role_id = "manager", actor_id = u$id)
  testthat::expect_true(gr$success)

  during <- assignment_actors(role_id = "manager")
  testthat::expect_true(u$id %in% during$id)

  rv <- assignment_revoke(role_id = "manager", actor_id = u$id)
  testthat::expect_true(rv$success)

  after <- assignment_actors(role_id = "manager")
  after_ids <- if ("id" %in% names(after)) after$id else integer(0)
  testthat::expect_false(u$id %in% after_ids)
})

test_that("assignment grant/revoke are version gated", {
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

  # Unknown Actors fail with 404, after the version gate warning
  testthat::expect_warning(
    testthat::expect_error(
      assignment_grant(
        role_id = "manager",
        actor_id = 999999999,
        odkc_version = "0.4"
      )
    ),
    "supported from v0.5"
  )
  testthat::expect_warning(
    testthat::expect_error(
      assignment_revoke(
        role_id = "manager",
        actor_id = 999999999,
        odkc_version = "0.4"
      )
    ),
    "supported from v0.5"
  )
})

test_that("assignment grant/revoke reject missing IDs", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    assignment_grant(role_id = NA, actor_id = 1, url = url, un = un, pw = pw),
    "single Role ID"
  )
  testthat::expect_error(
    assignment_grant(
      role_id = "manager",
      actor_id = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "single Actor ID"
  )
  testthat::expect_error(
    assignment_revoke(role_id = NA, actor_id = 1, url = url, un = un, pw = pw),
    "single Role ID"
  )
})

# usethis::use_r("assignment_grant")  # nolint
