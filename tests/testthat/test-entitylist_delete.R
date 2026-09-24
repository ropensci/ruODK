test_that("entitylist_delete soft-deletes an Entity List", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  skip_if(
    semver_lt(get_test_odkc_version(), "2026.1"),
    message = "Entity List deletion needs ODK Central 2026.1"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  dname <- glue::glue(
    "ruodk_test_del_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  entitylist_create(name = dname)

  d <- entitylist_delete(did = dname)
  testthat::expect_equal(d$success, TRUE)

  ell <- entitylist_list()
  testthat::expect_false(dname %in% ell$name)
})

test_that("entitylist_delete rejects a missing Entity List name", {
  testthat::expect_error(
    entitylist_delete(
      did = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "Entity List"
  )
})

# usethis::use_r("entitylist_delete")  # nolint
