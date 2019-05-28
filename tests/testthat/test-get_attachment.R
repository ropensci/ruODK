context("test-get_attachment.R")

test_that("get_attachment works", {
  data_url <- Sys.getenv("ODKC_TEST_URL")
  fresh_raw <- get_submissions(data_url)
  fresh_parsed <- fresh_raw %>% parse_submissions() %>%
    dplyr::rename(uuid=`.__id`) %>%
    dplyr::mutate(
      quadrat_photo = get_attachment(
        data_url, uuid, quadrat_photo, local_dir = tempdir(), verbose=TRUE))
  expect_gte(nrow(fresh_parsed), 2) # submissions at the time of writing
  expect_true(file.exists(fresh_parsed$quadrat_photo[[1]]))
})
