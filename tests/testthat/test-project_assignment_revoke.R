test_that("project_assignment_revoke rejects missing IDs", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    project_assignment_revoke(
      pid = 1,
      role_id = NA,
      actor_id = 1,
      url = url,
      un = un,
      pw = pw
    ),
    "single Role ID"
  )
  testthat::expect_error(
    project_assignment_revoke(
      pid = 1,
      role_id = "manager",
      actor_id = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "single Actor ID"
  )
})

# usethis::use_r("project_assignment_revoke")  # nolint
