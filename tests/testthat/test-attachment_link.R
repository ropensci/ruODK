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
