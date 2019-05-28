context("test-get_attachment.R")

test_that("get_attachment works", {
  data_url <- Sys.getenv("ODKC_TEST_URL")
  fresh_raw <- get_submissions(data_url)
  fresh_parsed <- fresh_raw %>%
    parse_submissions() %>%
    dplyr::rename(uuid = `.__id`) %>%
    dplyr::mutate(
      quadrat_photo = get_attachment(
        data_url, uuid, quadrat_photo,
        local_dir = tempdir(), verbose = TRUE
      )
    )
  expect_gte(nrow(fresh_parsed), 2) # submissions at the time of writing
  expect_true(file.exists(fresh_parsed$quadrat_photo[[1]]))
})

test_that("attachment_url works", {
  data_url <- "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-2_1558575936.svc"
  uuid <- "uuid:c0f9ce58-4388-4e7b-98d7-feac459d2e12"
  fn <- "1558579592153.jpg"

  expected_url <- "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-2_1558575936/submissions/uuid:c0f9ce58-4388-4e7b-98d7-feac459d2e12/attachments/1558579592153.jpg"
  calculated_url <- attachment_url(data_url, uuid, fn)

  expect_equal(calculated_url, expected_url)
})