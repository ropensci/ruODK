test_that("entity_changes warns if odkc_version too low", {
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

  # Unknown Entities fail with 404, after the version gate warning
  testthat::expect_warning(
    testthat::expect_error(
      entity_changes(
        did = "no-such-list",
        eid = "no-such-entity",
        odkc_version = "2022.2"
      )
    ),
    "supported from v2022.3"
  )
})

# usethis::use_r("entity_changes")  # nolint
