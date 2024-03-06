test_that("attachment_get works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  # nolint start
  # This is needed to run the tests for this file only
  # if (is.null(vcr::vcr_configuration()$write_disk_path)) {
  #   vcr::vcr_configure(write_disk_path = "../files")
  # }

  # wdp <- vcr::vcr_configuration()$write_disk_path
  # testthat::expect_true(
  #   fs::is_dir(wdp),
  #   label = glue::glue("VCR write_disk_path must exist: {wdp}")
  # )

  # t <- fs::path(wdp, "attachment_get")
  # fs::dir_create(t)
  # fs::dir_ls(t) %>% fs::file_delete()
  # nolint end
  t <- tempdir()

  # vcr::use_cassette("test_attachment_get0", {  # nolint
  fresh_raw <- odata_submission_get(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    parse = FALSE,
    verbose = TRUE
  )
  # })

  # vcr::use_cassette("test_attachment_get1", {  # nolint
  fresh_parsed <- fresh_raw %>%
    odata_submission_rectangle() %>%
    dplyr::mutate(
      # HTTPS request downloads a file  # nolint
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
  # }) # nolint

  # vcr::use_cassette("test_attachment_get2", {  # nolint
  fresh_parsed_sep <- fresh_raw %>%
    odata_submission_rectangle() %>%
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
  # })  # nolint

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
    "{url}/v1/projects/{pid}/forms/{fid}/",
    "submissions/{uuid}/attachments/{fn}"
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
  # This test checks behaviour upon multiple downloads of the same file.
  # Uncached, real-life behaviour is preferred here.
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  t <- tempdir()
  testthat::expect_true(fs::dir_exists(t))
  fs::dir_ls(t) %>% fs::file_delete()

  url <- get_test_url()
  un <- get_test_un()
  pw <- get_test_pw()
  pid <- get_test_pid()
  fid <- get_test_fid()
  ruODK::ru_setup(url=url, un=un, pw=pw)
  iid <- ruODK::submission_list(pid = pid, fid = fid)$instance_id
  att_list <- ruODK::attachment_list(pid = pid, fid = fid, iid = iid)
  fn <- att_list$name[1]
  pth <- fs::path(t, fn)

  src <- ruODK:::attachment_url(
    iid,
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
    fn,
    src,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    verbose = TRUE
  )

  gg <- get_one_attachment(
    pth,
    fn,
    src,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    verbose = TRUE
  )

  testthat::expect_equal(gg, as.character(pth))
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

  gg <- get_one_attachment(
    pth2,
    NA,
    src,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    verbose = TRUE
  )
  testthat::expect_true(is.na(gg))
})

# usethis::use_r("attachment_get") # nolint
