test_that("project_create works", {

  # nolint start
  #  p <- project_create(
  #   "Test Project",
  #   url = Sys.getenv("ODKC_TEST_URL"),
  #   un = Sys.getenv("ODKC_TEST_UN"),
  #   pw = Sys.getenv("ODKC_TEST_PW")
  # )
  # testthat::expect_equal(nrow(p), 1)
  #
  # # project_create returns a tibble
  # testthat::expect_equal(class(p), c("tbl_df", "tbl", "data.frame"))
  #
  # # Project metadata (some) are the tibble's columns
  # cn <- c(
  #   "id", "name", "archived"
  # )
  # testthat::expect_equal(names(p), cn)
  # nolint end

  testthat::expect_warning(
    project_create(
      "Test Project",
      url = Sys.getenv("ODKC_TEST_URL"),
      un = Sys.getenv("ODKC_TEST_UN"),
      pw = Sys.getenv("ODKC_TEST_PW")
    ), "Not implemented."
  )
})

# usethis::edit_file("R/project_create.R") # nolint
