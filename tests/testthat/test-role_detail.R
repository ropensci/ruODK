test_that("role_detail shows one Role by ID or system name", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  by_name <- role_detail(
    "admin",
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(nrow(by_name), 1)
  testthat::expect_equal(by_name$system, "admin")

  by_id <- role_detail(
    by_name$id,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(by_id$id, by_name$id)
  testthat::expect_true(length(by_id$verbs[[1]]) >= 1)
})

test_that("role_detail rejects a missing role id", {
  testthat::expect_error(
    role_detail(url = "http://localhost", un = "user", pw = "password"),
    "single Role ID"
  )
})

# usethis::use_r("role_detail")  # nolint
