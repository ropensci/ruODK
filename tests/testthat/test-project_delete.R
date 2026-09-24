test_that("project_delete removes a Project", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  pname <- glue::glue(
    "ruODK test project {format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  p <- project_create(
    pname,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  d <- project_delete(
    pid = p$id,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(d$success, TRUE)

  pl <- project_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_false(p$id %in% pl$id)

  # Deleting twice is rejected by Central.
  testthat::expect_error(
    project_delete(
      pid = p$id,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )
})

test_that("project_delete rejects missing input", {
  testthat::expect_error(
    project_delete(url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("project_delete")  # nolint
