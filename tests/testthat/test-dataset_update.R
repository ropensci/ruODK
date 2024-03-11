test_that("dataset_update works", {

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  ds <- dataset_list()

  ds1 <- dataset_detail(did = ds$name[1])

  did <- ds$name[1]

  # Update dataset with opposite approvalRequired
  ds2 <- dataset_update(did = did, approval_required=!ds1$approvalRequired)
  testthat::expect_false(ds1$approvalRequired == ds2$approvalRequired)

  # Update dataset with opposite approvalRequired again
  ds3 <- dataset_update(did = did, approval_required=!ds2$approvalRequired)
  testthat::expect_false(ds2$approvalRequired == ds3$approvalRequired)
  testthat::expect_true(ds1$approvalRequired == ds3$approvalRequired)
})


test_that("dataset_update warns if odkc_version too low", {
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

  ds <- dataset_list()
  did <- ds$name[1]

  ds1 <- dataset_update(did = did)

  testthat::expect_warning(
    ds1 <- dataset_update(did = did, odkc_version = "1.5.3")
  )

})