# Test the odata_entitylist_metadata_get function
test_that("odata_entitylist_metadata_get works correctly with valid inputs", {
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

  ds1 <- odata_entitylist_metadata_get(did = ds$name[1])

  # Check the structure of the result
  testthat::expect_s3_class(ds1, "odata_entitylist_metadata_get")
  # testthat::expect_equal(nrow(ds1$value), 1)
  # testthat::expect_equal(ds1$value$name[1], "Entities")
})

test_that("odata_entitylist_service_get print works", {
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

  ds1 <- odata_entitylist_metadata_get(did = ds$name[1])

  # Test print
  out <- testthat::capture_output(print(ds1))
  testthat::expect_true(any(grepl("<ruODK OData EntityList Metadata>", out)))
  testthat::expect_true(any(grepl(glue::glue("Complex Types"), out)))
  testthat::expect_true(any(grepl(glue::glue("Entity Types"), out)))
  testthat::expect_true(any(grepl(glue::glue("Containers"), out)))
})


test_that("odata_entitylist_metadata_get warns on missing arguments", {
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

  testthat::expect_error(
    odata_entitylist_metadata_get(pid = "", did = "")
  )

  testthat::expect_error(
    odata_entitylist_metadata_get(pid = get_test_pid(), did = "")
  )
})


test_that("odata_entitylist_metadata_get warns if odkc_version too low", {
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

  ds1 <- odata_entitylist_metadata_get(did = did)

  testthat::expect_warning(
    ds1 <- odata_entitylist_metadata_get(did = did, odkc_version = "1.5.3")
  )
})

# usethis::use_r("odata_entitylist_metadata_get") # nolint
