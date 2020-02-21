context("test-odata_submission_rectangle.R")

test_that("odata_submission_rectangle works", {
  data_parsed <- odata_submission_rectangle(fq_raw, verbose = TRUE)

  # Field "device_id" is known part of fq_raw
  testthat::expect_equal(
    data_parsed$device_id[[1]],
    fq_raw$value[[1]]$device_id
  )

  # fq_raw has two submissions
  testthat::expect_equal(length(fq_raw$value), nrow(data_parsed))
})

# Tests code
# usethis::use_r("odata_submission_rectangle")
