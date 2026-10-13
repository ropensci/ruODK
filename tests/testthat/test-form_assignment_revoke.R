test_that("form_assignment_revoke rejects missing IDs", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    form_assignment_revoke(
      pid = 1,
      fid = "f",
      role_id = NA,
      actor_id = 1,
      url = url,
      un = un,
      pw = pw
    ),
    "single Role ID"
  )
  testthat::expect_error(
    form_assignment_revoke(
      pid = 1,
      fid = "f",
      role_id = "manager",
      actor_id = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "single Actor ID"
  )
})

# usethis::use_r("form_assignment_revoke")  # nolint
