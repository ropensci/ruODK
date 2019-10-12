test_that("lifecycle_shim does nothing as expected", {
  testthat::expect_warning(ruODK:::lifecycle_shim())
})
