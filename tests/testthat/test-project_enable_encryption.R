test_that("project_enable_encryption enables encryption", {
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

  p <- project_create(
    name = glue::glue(
      "ruodk_enc_{format(Sys.time(), '%Y%m%d%H%M%S')}"
    ) |>
      as.character()
  )

  withr::defer(
    project_delete(
      pid = p$id,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  pe <- project_enable_encryption(
    pid = p$id,
    passphrase = "super duper secret",
    hint = "it was a secret"
  )
  testthat::expect_true(pe$success)

  # Enabling twice fails with 409, after the version gate warning
  testthat::expect_warning(
    testthat::expect_error(
      project_enable_encryption(
        pid = p$id,
        passphrase = "super duper secret",
        odkc_version = "0.5"
      )
    ),
    "supported from v0.6"
  )
})

test_that("project_enable_encryption rejects a missing passphrase", {
  testthat::expect_error(
    project_enable_encryption(
      pid = 1,
      passphrase = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
  testthat::expect_error(
    project_enable_encryption(
      pid = "",
      passphrase = "secret",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("project_enable_encryption")  # nolint
