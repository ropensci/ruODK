test_that("assignment_revoke rejects missing IDs", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    assignment_revoke(role_id = NA, actor_id = 1, url = url, un = un, pw = pw),
    "single Role ID"
  )
  testthat::expect_error(
    assignment_revoke(
      role_id = "manager",
      actor_id = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "single Actor ID"
  )
})

# usethis::use_r("assignment_revoke")  # nolint
