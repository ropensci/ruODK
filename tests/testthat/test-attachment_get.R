context("test-attachment_get.R")

test_that("attachment_get works", {
  pid <- 14
  fid <- "build_Flora-Quadrat-0-2_1558575936"
  url <- "https://sandbox.central.opendatakit.org"
  fresh_raw <- odata_submissions_get(
    Sys.getenv("ODKC_TEST_PID"),
    Sys.getenv("ODKC_TEST_FID"),
    url = Sys.getenv("ODKC_TEST_URL"),
    un = Sys.getenv("ODKC_TEST_UN"),
    pw = Sys.getenv("ODKC_TEST_PW")
  )
  fresh_parsed <- fresh_raw %>%
    parse_submissions() %>%
    dplyr::rename(uuid = `.__id`) %>%
    dplyr::mutate(
      quadrat_photo = attachment_get(
        pid, fid, uuid, quadrat_photo,
        local_dir = tempdir(), url = url, verbose = TRUE
      )
    )
  # submissions at the time of writing
  testthat::expect_gte(nrow(fresh_parsed), length(fresh_raw$value))
  testthat::expect_true(fs::file_exists(fresh_parsed$quadrat_photo[[1]]))
})

test_that("attachment_url works", {
  uuid <- "uuid:c0f9ce58-4388-4e7b-98d7-feac459d2e12"
  fn <- "1558579592153.jpg"
  pid <- 14
  fid <- "build_Flora-Quadrat-0-2_1558575936"
  url <- "https://sandbox.central.opendatakit.org"

  expected_url <- glue::glue(
    "{url}/v1/projects/14/forms/{fid}/",
    "submissions/{uuid}/attachments/{fn}"
  )
  calculated_url <- ruODK:::attachment_url(pid, fid, uuid, fn, url)

  testthat::expect_equal(calculated_url, expected_url)
})

test_that("get_one_attachment handles repeat download and NA filenames", {
  uuid <- "uuid:c0f9ce58-4388-4e7b-98d7-feac459d2e12"
  fn <- "1558579592153.jpg"
  pid <- 14
  fid <- "build_Flora-Quadrat-0-2_1558575936"
  url <- "https://sandbox.central.opendatakit.org"

  pth <- fs::path(tempdir(), fn)
  src <- ruODK:::attachment_url(pid, fid, uuid, fn, url)

  # Happy path: get one attachment should work
  testthat::expect_message(
    get_one_attachment(pth, fn, src, verbose = TRUE),
    glue::glue("Saved {pth}\n")
  )
  fn_local <- get_one_attachment(pth, fn, src, verbose = TRUE)
  testthat::expect_true(fs::file_exists(pth))
  testthat::expect_equal(fn_local, as.character(pth))

  # Happy, but faster: keep existing download
  testthat::expect_message(
    get_one_attachment(pth, fn, src, verbose = TRUE),
    glue::glue("Keeping {pth}\n")
  )

  # Not happy, but tolerant: keep file at pth if exists
  testthat::expect_message(
    get_one_attachment(pth, NA, src, verbose = TRUE),
    glue::glue("Keeping {pth}\n")
  )
  testthat::expect_equal(
    get_one_attachment(pth, NA, src, verbose = TRUE),
    as.character(pth)
  )

  # Now make sure pth doesn't exist
  pth <- fs::path(tempdir(), NA) %>% as.character()
  testthat::expect_message(
    get_one_attachment(pth, NA, src, verbose = TRUE),
    "Filename is NA, skipping download."
  )
  testthat::expect_true(is.na(get_one_attachment(pth, NA, src, verbose = TRUE)))
})
