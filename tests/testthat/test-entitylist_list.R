test_that("entitylist_list works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  ds <- entitylist_list()
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
    "owner_only",
    "entities",
    "last_entity",
    "conflicts"
  )
  testthat::expect_equal(names(ds), cn)
})


test_that("entitylist_list warns if odkc_version too low", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  ds <- entitylist_list()
  did <- ds$name[1]

  ds1 <- entitylist_list()

  testthat::expect_warning(
    ds1 <- entitylist_list(odkc_version = "1.5.3")
  )
})

# usethis::use_r("entitylist_list") # nolint
