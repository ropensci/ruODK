context("test-parse_submissions.R")

test_that("parse_submission_works", {
  data_parsed <- parse_submissions(fq_raw)

  # Field "device_id" is known part of fq_raw
  expect_equal(data_parsed$device_id[[1]], fq_raw$value[[1]]$device_id)

  # fq_raw has two submissions
  expect_equal(length(fq_raw$value), nrow(data_parsed))
})
