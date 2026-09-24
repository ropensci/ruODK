test_that("form_link finds a Form by Link ID", {
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

  fl <- form_list(pid = get_test_pid())
  testthat::skip_if_not(
    any(!is.na(fl$enketo_id)),
    message = "Enketo not configured, no enketo_id to look up"
  )
  enketo_id <- fl$enketo_id[!is.na(fl$enketo_id)][[1]]
  fid <- fl$fid[!is.na(fl$enketo_id)][[1]]

  f <- form_link(
    form_link_id = enketo_id,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(class(f), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_equal(nrow(f), 1)
  testthat::expect_equal(f$fid, fid)
})

test_that("form_link rejects a missing Link ID", {
  testthat::expect_error(
    form_link(url = "http://localhost", un = "user", pw = "password"),
    "single non-empty"
  )
  testthat::expect_error(
    form_link(
      form_link_id = "no-such-link",
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    ),
    "404"
  )
})

# usethis::use_r("form_link")  # nolint
