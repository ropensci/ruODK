context("test-attachment_get.R")

test_that("attachment_get works", {
  t <- tempdir()

  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  fresh_parsed <- fresh_raw %>%
    odata_submission_parse() %>%
    janitor::clean_names() %>%
    dplyr::mutate(
      quadrat_photo = attachment_get(
        id,
        quadrat_photo,
        local_dir = t,
        pid = get_test_pid(),
        fid = get_test_fid(),
        url = get_test_url(),
        un = get_test_un(),
        pw = get_test_pw(),
        verbose = TRUE
      )
    )

  # submissions at the time of writing
  testthat::expect_gte(nrow(fresh_parsed), length(fresh_raw$value))
  testthat::expect_true(fs::file_exists(fresh_parsed$quadrat_photo[[1]]))
})

test_that("attachment_url works", {
  uuid <- "uuid:c0f9ce58-4388-4e7b-98d7-feac459d2e12"
  fn <- "1558579592153.jpg"
  url <- get_test_url()
  pid <- get_test_pid()
  fid <- get_test_fid()

  expected_url <- glue::glue(
    "{url}/v1/projects/14/forms/{fid}/submissions/{uuid}/attachments/{fn}"
  )
  calculated_url <- ruODK:::attachment_url(
    uuid,
    fn,
    pid = pid,
    fid = fid,
    url = url
  )

  testthat::expect_equal(calculated_url, expected_url)
})

test_that("get_one_attachment handles repeat download and NA filenames", {
  t <- tempdir(check = TRUE)
  testthat::expect_true(fs::dir_exists(t))

  uuid <- "uuid:c0f9ce58-4388-4e7b-98d7-feac459d2e12"
  fn <- "1558579592153.jpg"
  url <- get_test_url()
  pid <- get_test_pid()
  fid <- get_test_fid()

  pth <- fs::path(t, fn)
  src <- ruODK:::attachment_url(uuid, fn, pid = pid, fid = fid, url = url)

  # Happy path: get one attachment should work
  testthat::expect_message(
    get_one_attachment(
      pth,
      fn,
      src,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      verbose = TRUE
    ),
    glue::glue("Saved {pth}\n")
  )

  fn_local <- get_one_attachment(
    pth,
    fn,
    src,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    verbose = TRUE
  )
  testthat::expect_true(fs::file_exists(pth))
  testthat::expect_equal(fn_local, as.character(pth))

  # Happy, but faster: keep existing download
  testthat::expect_message(
    get_one_attachment(
      pth,
      fn,
      src,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      verbose = TRUE
    ),
    glue::glue("Keeping {pth}\n")
  )

  # Not happy, but tolerant: keep file at pth if exists
  testthat::expect_message(
    get_one_attachment(
      pth,
      NA,
      src,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      verbose = TRUE
    ),
    glue::glue("Keeping {pth}\n")
  )
  testthat::expect_equal(
    get_one_attachment(
      pth,
      NA,
      src,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      verbose = TRUE
    ),
    as.character(pth)
  )

  # Now make sure pth doesn't exist
  pth2 <- fs::path(t, NA) %>% as.character()
  testthat::expect_message(
    get_one_attachment(
      pth2,
      NA,
      src,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      verbose = TRUE
    ),
    "Filename is NA, skipping download."
  )
  testthat::expect_true(
    is.na(
      get_one_attachment(
        pth2,
        NA,
        src,
        url = get_test_url(),
        un = get_test_un(),
        pw = get_test_pw(),
        verbose = TRUE
      )
    )
  )
})

# Tests code
# usethis::edit_file("R/attachment_get.R")
