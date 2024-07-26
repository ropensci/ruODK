test_that("entitylist_detail works", {
  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  ds <- entitylist_list()
  did <- ds$name[1]

  ds1 <- entitylist_detail(did = did)

  # entitylist_detail returns a list
  testthat::expect_is(ds1, "list")

  # linked_forms contain form xmlFormId and name
  lf <- ds1$linked_forms |>
    purrr::list_transpose() |>
    tibble::as_tibble()
  testthat::expect_equal(names(lf), c("xmlFormId", "name"))

  # source_forms contain form xmlFormId and name
  sf <- ds1$source_forms |>
    purrr::list_transpose() |>
    tibble::as_tibble()
  testthat::expect_equal(names(sf), c("xmlFormId", "name"))

  # properties lists attributes of entities
  pr <- ds1$properties |>
    purrr::list_transpose() |>
    tibble::as_tibble()
  testthat::expect_equal(
    names(pr),
    c("name", "publishedAt", "odataName", "forms")
  )
})

test_that("entitylist_detail errors if did is missing", {
  testthat::expect_error(
    entitylist_detail()
  )
})

test_that("entitylist_detail warns if odkc_version too low", {
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

  ds1 <- entitylist_detail(did = did)

  testthat::expect_warning(
    ds1 <- entitylist_detail(did = did, odkc_version = "1.5.3")
  )
})


# usethis::use_r("entitylist_detail") # nolint
