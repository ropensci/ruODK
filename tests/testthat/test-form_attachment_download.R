test_that("form_attachment_download fails without uploaded bytes", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  # XML-created Forms hold no bytes: Central answers 404.
  # Full download round-trips are covered once Draft uploads land.
  testthat::expect_error(
    form_attachment_download(
      fid = get_test_fid(),
      filename = "no-such-file.csv",
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )
})

test_that("form_attachment_download rejects missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    form_attachment_download(fid = "f", url = url, un = un, pw = pw),
    "single non-empty"
  )
  testthat::expect_error(
    form_attachment_download(
      fid = "f",
      filename = "a.csv",
      dest = 123,
      url = url,
      un = un,
      pw = pw
    ),
    "single file path"
  )
})

# usethis::use_r("form_attachment_download")  # nolint
