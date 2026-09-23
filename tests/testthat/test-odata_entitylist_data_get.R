test_that("odata_entitylist_data_get works correctly with valid inputs", {
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

  ds1 <- odata_entitylist_data_get(did = ds$name[1])

  # Check the structure of the result
  testthat::expect_s3_class(ds1, "odata_entitylist_data_get")
  testthat::expect_is(ds1$context, "character")
})


test_that("odata_entitylist_data_get filters work", {
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

  # `createdAt le <date>` must actually match something. Entities are stamped
  # at ingest, so a local stack seeded from fixtures gets today's date, not the
  # dates of the original server. A far-future bound matches on any stack while
  # still exercising $filter. $skip then trims the head of the result.
  qry <- list(
    "$filter" = "__system/createdAt le 2099-12-31",
    "$orderby" = "__system/creatorId ASC, __system/conflict DESC",
    "$top" = "100",
    "$skip" = "3",
    "$count" = "true"
  )
  ds1 <- odata_entitylist_data_get(did = ds$name[1], query = qry)

  # Check the structure of the result
  testthat::expect_s3_class(ds1, "odata_entitylist_data_get")
  testthat::expect_is(ds1$context, "character")
})

test_that("odata_entitylist_data_get returns an empty tibble when nothing matches", {
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

  # A filter that cannot match: the result has no `id` column to deduplicate
  # on, and must still be an empty tibble rather than an error.
  ds_empty <- odata_entitylist_data_get(
    did = ds$name[1],
    query = list("$filter" = "__system/createdAt le 1900-01-01")
  )
  testthat::expect_s3_class(ds_empty, "odata_entitylist_data_get")
  testthat::expect_equal(nrow(ds_empty$value), 0)
})

test_that("odata_entitylist_data_get print works", {
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

  ds1 <- odata_entitylist_data_get(did = ds$name[1])

  # Test print
  out <- testthat::capture_output(print(ds1))
  testthat::expect_true(any(grepl("<ruODK OData EntityList Data>", out)))
  testthat::expect_true(any(grepl(glue::glue("OData Context"), out)))
  testthat::expect_true(any(grepl(glue::glue("OData Entities"), out)))
})


test_that("odata_entitylist_data_get warns on missing arguments", {
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
    odata_entitylist_data_get(pid = "", did = "")
  )

  testthat::expect_error(
    odata_entitylist_data_get(pid = get_test_pid(), did = "")
  )
})


test_that("odata_entitylist_data_get warns if odkc_version too low", {
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

  ds1 <- odata_entitylist_data_get(did = did)

  testthat::expect_warning(
    ds1 <- odata_entitylist_data_get(did = did, odkc_version = "1.5.3")
  )
})

# usethis::use_r("odata_entitylist_data_get") # nolint
