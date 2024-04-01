test_that("entitylist_update works", {
  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  ds <- entitylist_list()

  ds1 <- entitylist_detail(did = ds$name[1])

  did <- ds$name[1]

  # Update dataset with opposite approval_required
  ds2 <- entitylist_update(did = did, approval_required = !ds1$approval_required)
  testthat::expect_false(ds1$approval_required == ds2$approval_required)

  # Update dataset with opposite approval_required again
  ds3 <- entitylist_update(did = did, approval_required = !ds2$approval_required)
  testthat::expect_false(ds2$approval_required == ds3$approval_required)
  testthat::expect_true(ds1$approval_required == ds3$approval_required)
})

test_that("entitylist_update errors if did is missing", {
  testthat::expect_error(
    entitylist_update()
  )
})

test_that("entitylist_update warns if odkc_version too low", {
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

  ds1 <- entitylist_update(did = did)

  testthat::expect_warning(
    ds1 <- entitylist_update(did = did, odkc_version = "1.5.3")
  )
})


# usethis::use_r("entitylist_update") # nolint
