test_that("entity_creators lists creating Actors", {
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
  cr <- entity_creators(did = el$name[1])

  testthat::expect_equal(class(cr), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true(all(c("id", "display_name", "type") %in% names(cr)))
  testthat::expect_gte(nrow(cr), 1)
})

test_that("entity_creators rejects a missing Entity List name", {
  testthat::expect_error(
    entity_creators(
      did = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "Entity List"
  )
})

# usethis::use_r("entity_creators")  # nolint
