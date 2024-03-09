test_that("dataset_list works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
          message = "Test server not configured"
  )

  ds <- dataset_list(
    get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  testthat::expect_true(nrow(ds) > 0)
  testthat::expect_true("name" %in% names(ds))

  # function returns a tibble
  testthat::expect_s3_class(ds, "tbl_df")

  # Expected column names
  cn <- c(
    "name",
    "created_at",
    "project_id",
    "approval_required",
    "entities",
    "last_entity",
    "conflicts"
  )
  testthat::expect_equal(names(ds), cn)
})


test_that("dataset_list warns if odkc_version too low", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
          message = "Test server not configured"
  )

  ds <- dataset_list(
    get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = "2022.3"
  )

  testthat::expect_warning(
    ds <- dataset_list(
      get_test_pid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      odkc_version = "1.5.3"
    )
  )

})