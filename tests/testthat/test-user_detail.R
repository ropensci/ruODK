test_that("user_detail shows the authenticated User", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  me <- user_detail(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(nrow(me), 1)
  testthat::expect_true(nzchar(me$display_name))
  testthat::expect_equal(me$type, "user")

  by_id <- user_detail(
    actor_id = me$id,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(by_id$id, me$id)
  testthat::expect_equal(by_id$email, me$email)
})

test_that("user_detail rejects invalid input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    user_detail(actor_id = NA, url = url, un = un, pw = pw),
    "single User ID"
  )
  testthat::expect_error(
    user_detail(extended = TRUE, url = "", un = un, pw = pw),
    "Missing ODK Central"
  )
  testthat::expect_error(
    user_detail(actor_id = 1, extended = TRUE, url = url, un = un, pw = pw),
    "needs actor_id 'current'"
  )
})

# usethis::use_r("user_detail")  # nolint
