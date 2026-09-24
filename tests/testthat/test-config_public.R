test_that("config_public shows public configuration", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  skip_if(
    semver_lt(get_test_odkc_version(), "2026.1"),
    message = "Public configuration needs ODK Central 2026.1"
  )

  cfg <- config_public(url = get_test_url())
  testthat::expect_true(is.list(cfg))
})

test_that("config_public rejects a missing URL", {
  testthat::expect_error(
    config_public(url = ""),
    "Missing ODK Central URL"
  )
})

# usethis::use_r("config_public")  # nolint
