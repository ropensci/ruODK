test_that("dataset_update works", {


  ds <- dataset_list(pid = get_default_pid(),
                     url = get_test_url(),
                     un = get_test_un(),
                     pw = get_test_pw(),
                     odkc_version = get_test_odkc_version())

  ds1 <- dataset_detail(pid = get_default_pid(),
                        did = ds$name[1],
                        url = get_test_url(),
                        un = get_test_un(),
                        pw = get_test_pw(),
                        odkc_version = get_test_odkc_version())

  pid <- get_default_pid()
  did <- ds$name[1]

  # Update dataset with opposite approvalRequired
  ds2 <- dataset_update(pid = pid, did = did, approval_required=!ds1$approvalRequired)
  testthat::expect_false(ds1$approvalRequired == ds2$approvalRequired)

  # Update dataset with opposite approvalRequired again
  ds3 <- dataset_update(pid = pid, did = did, approval_required=!ds2$approvalRequired)
  testthat::expect_false(ds2$approvalRequired == ds3$approvalRequired)
  testthat::expect_true(ds1$approvalRequired == ds3$approvalRequired)
})


test_that("dataset_update warns if odkc_version too low", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
          message = "Test server not configured"
  )

  ds <- dataset_list(pid = get_default_pid(),
                     url = get_test_url(),
                     un = get_test_un(),
                     pw = get_test_pw(),
                     odkc_version = "2022.3")

  ds1 <- dataset_update(
    pid = get_test_pid(),
    did = ds$name[1],
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = "2022.3"
  )

  testthat::expect_warning(
    ds1 <- dataset_update(
      pid = get_test_pid(),
      did = ds$name[1],
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      odkc_version = "1.5.3"
    )
  )

})