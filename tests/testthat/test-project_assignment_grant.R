test_that("project_assignment grant/revoke roundtrip works", {
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

  # Any existing Actor will do; the seed admin carries no explicit
  # project-level Manager assignment, so the listing starts empty
  actor_id <- assignment_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )$actor_id[[1]]

  before <- project_assignment_actors(
    pid = get_test_pid(),
    role_id = "manager"
  )
  testthat::expect_equal(nrow(before), 0)

  gr <- project_assignment_grant(
    pid = get_test_pid(),
    role_id = "manager",
    actor_id = actor_id
  )
  testthat::expect_true(gr$success)

  during <- project_assignment_actors(
    pid = get_test_pid(),
    role_id = "manager"
  )
  testthat::expect_true(actor_id %in% during$id)

  rv <- project_assignment_revoke(
    pid = get_test_pid(),
    role_id = "manager",
    actor_id = actor_id
  )
  testthat::expect_true(rv$success)

  after <- project_assignment_actors(
    pid = get_test_pid(),
    role_id = "manager"
  )
  testthat::expect_equal(nrow(after), 0)
})

test_that("project_assignment functions are version gated", {
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
    project_assignment_actors(
      pid = get_test_pid(),
      role_id = "manager",
      odkc_version = "0.4"
    ),
    "supported from v0.5"
  )
  # Unknown Actors fail with 404, after the version gate warning
  testthat::expect_warning(
    testthat::expect_error(
      project_assignment_grant(
        pid = get_test_pid(),
        role_id = "manager",
        actor_id = 999999999,
        odkc_version = "0.4"
      )
    ),
    "supported from v0.5"
  )
  testthat::expect_warning(
    testthat::expect_error(
      project_assignment_revoke(
        pid = get_test_pid(),
        role_id = "manager",
        actor_id = 999999999,
        odkc_version = "0.4"
      )
    ),
    "supported from v0.5"
  )
})

test_that("project_assignment functions reject missing IDs", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    project_assignment_actors(
      pid = 1,
      role_id = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "single Role ID"
  )
  testthat::expect_error(
    project_assignment_grant(
      pid = 1,
      role_id = "manager",
      actor_id = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "single Actor ID"
  )
  testthat::expect_error(
    project_assignment_revoke(
      pid = "",
      role_id = "manager",
      actor_id = 1,
      url = url,
      un = un,
      pw = pw
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("project_assignment_grant")  # nolint
