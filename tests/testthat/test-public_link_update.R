test_that("public_link_update validates properties", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    public_link_update(
      fid = "f",
      link_id = 1,
      properties = list("x"),
      url = url,
      un = un,
      pw = pw
    ),
    "named list"
  )
  testthat::expect_error(
    public_link_update(
      fid = "f",
      link_id = 1,
      properties = list("region" = 42),
      url = url,
      un = un,
      pw = pw
    ),
    "named list"
  )
  testthat::expect_error(
    public_link_update(
      fid = "f",
      properties = list("region" = "North"),
      url = url,
      un = un,
      pw = pw
    ),
    "single Link ID"
  )
})

# Live coverage needs pre-registered Actor Properties on the Project,
# which the shared test instance does not provide. Once such a Project
# exists, post `properties = list("<name>" = "<value>")` and expect the
# returned Link to hold them.

# usethis::use_r("public_link_update")  # nolint
