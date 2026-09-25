test_that("project_create returns a one-row tibble of project metadata", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # Unique name per run: project_create is a write, and the test suite does
  # not roll back (cf. test-entity_create.R).
  pname <- as.character(
    glue::glue("ruODK test project {format(Sys.time(), '%Y%m%d%H%M%S')}")
  )

  p <- project_create(
    pname,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  # project_create is a write and ruODK has no project_delete(). Remove the
  # Project again so a run against a shared ODK Central does not accumulate
  # test projects. withr::defer() runs even when an expectation fails below.
  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", p$id),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  testthat::expect_equal(nrow(p), 1)
  testthat::expect_equal(class(p), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true(all(c("id", "name", "archived") %in% names(p)))
  testthat::expect_equal(p$name, pname)
  testthat::expect_true(is.numeric(p$id) || is.integer(p$id))

  # The new Project is listed with the same id and name.
  pl <- project_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_true(p$id %in% pl$id)
  testthat::expect_equal(pl$name[pl$id == p$id][[1]], pname)
})

test_that("project_create rejects a missing or empty name", {
  testthat::expect_error(
    project_create(
      "",
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    ),
    "non-empty"
  )
  testthat::expect_error(
    project_create(
      c("a", "b"),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    ),
    "non-empty"
  )
})

# usethis::use_r("project_create") # nolint
