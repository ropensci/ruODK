context("test-get_metadata.R")

test_that("get_metadata works", {
  library(xml2)
  data_url <- Sys.getenv("ODKC_TEST_URL")
  md <- get_metadata(data_url)
  expect_equal(class(md), "list")
})
