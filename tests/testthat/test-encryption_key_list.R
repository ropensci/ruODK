test_that("encryption_key_list works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  vcr::use_cassette("test_encryption_key_list0", {
    x <- encryption_key_list(
      pid = Sys.getenv("ODKC_TEST_PID_ENC"),
      fid = Sys.getenv("ODKC_TEST_FID_ENC"),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )

    cn <- c(
      "id",
      "public",
      "managed",
      "hint",
      "created_at"
    )

    purrr::map(
      cn,
      ~ testthat::expect_true(
        . %in% names(x),
        label = glue::glue("Column {.} missing from encryption_key_list")
      )
    )
  })
})


# usethis::use_r("encryption_key_list")  # nolint
