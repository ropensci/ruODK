test_that("form_schema_parse warns not implemented", {
    testthat::expect_warning(
      form_schema_parse(list()),
      "Not implemented."
  )
})


test_that("prefix_fn works", {
  testthat::expect_equal(
    prefix_fn(fn = "test.txt", prefix = "somefolder"),
    "somefolder/test.txt"
  )
})

test_that("attachment_link warns not implemented", {
  testthat::expect_warning(
    attachment_link(tibble::tibble(a=1:10, b=20:30),
                    Sys.getenv("ODKC_TEST_PID"),
                    Sys.getenv("ODKC_TEST_FID"),
                    url = Sys.getenv("ODKC_TEST_URL"),
                    un = Sys.getenv("ODKC_TEST_UN"),
                    pw = Sys.getenv("ODKC_TEST_PW")),
    "Not implemented."
  )
})