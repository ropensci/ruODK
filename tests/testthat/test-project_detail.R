test_that("project_detail works", {
  p <- project_detail(
    Sys.getenv("ODKC_TEST_PID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  testthat::expect_true(nrow(p) == 1)
  testthat::expect_true("name" %in% names(p))

  # project_detail returns a tibble
  testthat::expect_equal(class(p), c("tbl_df", "tbl", "data.frame"))

  # Project metadata are the tibble's columns
  cn <- c(
    "id", "name", "forms", "app_users", "last_submission",
    "created_at", "updated_at", "archived", "verbs"
  )
  testthat::expect_equal(names(p), cn)
})

# Tests
# usethis::edit_file("R/project_detail.R")
