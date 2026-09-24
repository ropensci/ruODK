test_that("entity_bulk_restore rejects missing UUIDs", {
  testthat::expect_error(
    entity_bulk_restore(
      did = "trees",
      eids = 123,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "one or more"
  )
})

# Live coverage lives in test-entity_bulk_delete.R, which round-trips
# bulk delete and bulk restore against the test server.

# usethis::use_r("entity_bulk_restore")  # nolint
