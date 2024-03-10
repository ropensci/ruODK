test_that("dataset_detail works", {

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

  # dataset_detail returns a list
  testthat::expect_is(ds1, "list")

  # linkedForms contain form xmlFormId and name
  lf <- ds1$linkedForms |> purrr::list_transpose() |> tibble::as_tibble()
  testthat::expect_equal(names(lf), c("xmlFormId", "name" ))

  # sourceForms contain form xmlFormId and name
  sf <- ds1$sourceForms |> purrr::list_transpose() |> tibble::as_tibble()
  testthat::expect_equal(names(sf), c("xmlFormId", "name" ))

  # properties lists attributes of entities
  pr <- ds1$properties |> purrr::list_transpose() |> tibble::as_tibble()
  testthat::expect_equal(names(pr), c("name", "publishedAt", "odataName", "forms"))
})


test_that("dataset_detail warns if odkc_version too low", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
          message = "Test server not configured"
  )

  ds <- dataset_list(pid = get_default_pid(),
                     url = get_test_url(),
                     un = get_test_un(),
                     pw = get_test_pw(),
                     odkc_version = "2022.3")

  ds1 <- dataset_detail(
    pid = get_test_pid(),
    did = ds$name[1],
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = "2022.3"
  )

  testthat::expect_warning(
    ds1 <- dataset_detail(
      pid = get_test_pid(),
      did = ds$name[1],
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      odkc_version = "1.5.3"
    )
  )

})