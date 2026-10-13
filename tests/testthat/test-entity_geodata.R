test_that("entity_geodata returns a GeoJSON FeatureCollection", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  el <- entitylist_list()
  g <- entity_geodata(did = el$name[1])

  testthat::expect_equal(g$type, "FeatureCollection")
  testthat::expect_true(is.list(g$features))
})

test_that("entity_geodata rejects a missing Entity List name", {
  testthat::expect_error(
    entity_geodata(
      did = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "Entity List"
  )
})

test_that("entity_geodata warns if odkc_version too low", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  # Unknown objects fail with 404, after the version gate warning
  testthat::expect_warning(
    testthat::expect_error(
      entity_geodata(
        did = "no-such-list",
        odkc_version = "2022.2"
      )
    ),
    "supported from v2022.3"
  )
})

# usethis::use_r("entity_geodata")  # nolint
