test_that("lifecycle_shim does nothing as expected", {
  testthat::capture_warning(ruODK:::lifecycle_shim())
  testthat::expect_true(TRUE)
})
