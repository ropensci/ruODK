context("test-attachment_get.R")

test_that("attachment_get works", {
  t <- tempdir()

  fs::dir_ls(t) %>% fs::file_delete()

  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    parse = FALSE
  )

  fresh_parsed <- fresh_raw %>%
    odata_submission_parse() %>%
    dplyr::mutate(
      quadrat_photo = attachment_get(
        id,
        location_quadrat_photo,
        local_dir = t,
        pid = get_test_pid(),
        fid = get_test_fid(),
        url = get_test_url(),
        un = get_test_un(),
        pw = get_test_pw(),
        verbose = TRUE
      )
    )

  fresh_parsed_sep <- fresh_raw %>%
    odata_submission_parse() %>%
    dplyr::mutate(
      quadrat_photo = attachment_get(
        id,
        location_quadrat_photo,
        local_dir = t,
        separate = TRUE,
        pid = get_test_pid(),
        fid = get_test_fid(),
        url = get_test_url(),
        un = get_test_un(),
        pw = get_test_pw(),
        verbose = TRUE
      )
    )

  # Attachment paths should be character, not e.g. list (pmap outputs lists)
  testthat::expect_equal(class(fresh_parsed$quadrat_photo), "character")

  # submissions at the time of writing
  testthat::expect_gte(nrow(fresh_parsed), length(fresh_raw$value))
  testthat::expect_true(fs::file_exists(fresh_parsed$quadrat_photo[[1]]))
  testthat::expect_true(fs::file_exists(fresh_parsed_sep$quadrat_photo[[1]]))
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
  calculated_url <- ruODK:::attachment_url(uuid,
    fn,
    pid = pid,
    fid = fid,
    url = url
  )

  testthat::expect_equal(calculated_url, expected_url)
})

test_that("get_one_attachment handles repeat download and NA filenames", {
  t <- tempdir()
  testthat::expect_true(fs::dir_exists(t))
  fs::dir_ls(t) %>% fs::file_delete()

  # Brittle: depends on data collected for example form
  uuid <- "uuid:529cb189-8bb2-4cf1-9041-dcde716efb4f"
  fn <- "1568786958640.jpg"

  url <- get_test_url()
  pid <- get_test_pid()
  fid <- get_test_fid()

  pth <- fs::path(t, fn)
  src <- ruODK:::attachment_url(uuid,
    fn,
    pid = pid,
    fid = fid,
    url = url
  )

  # Happy path: get one attachment should work
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
  first_dl_time <- fs::file_info(fn_local)$modification_time
  testthat::expect_equal(fn_local, as.character(pth))

  # Happy, but faster: keep existing download
  fn_retained <- get_one_attachment(
    pth,
    fn,
    src,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    verbose = TRUE
  )

  testthat::expect_true(fs::file_exists(pth))
  testthat::expect_equal(fn_retained, as.character(pth))
  testthat::expect_equal(first_dl_time, fs::file_info(pth)$modification_time)

  # Not happy, but tolerant: keep file at pth if exists
  get_one_attachment(
    pth,
    NA,
    src,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    verbose = TRUE
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
  testthat::expect_equal(first_dl_time, fs::file_info(pth)$modification_time)

  # Now make sure pth doesn't exist
  pth2 <- fs::path(t, NA) %>% as.character()
  get_one_attachment(
    pth2,
    NA,
    src,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    verbose = TRUE
  )
  testthat::expect_true(is.na(
    get_one_attachment(
      pth2,
      NA,
      src,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      verbose = TRUE
    )
  ))
})

# Tests code
# usethis::edit_file("R/attachment_get.R")
