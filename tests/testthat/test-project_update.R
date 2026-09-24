test_that("project_update patches name, description and archived flag", {
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

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", p$id),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  u <- project_update(
    pid = p$id,
    description = "Patched by ruODK test.",
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(u$name, pname)
  testthat::expect_equal(u$description, "Patched by ruODK test.")

  u <- project_update(
    pid = p$id,
    name = paste0(pname, " renamed"),
    archived = TRUE,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(u$name, paste0(pname, " renamed"))
  testthat::expect_equal(u$archived, TRUE)

  pd <- project_detail(
    pid = p$id,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(pd$name, paste0(pname, " renamed"))
})

test_that("project_update rejects missing or invalid input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    project_update(pid = 1, url = url, un = un, pw = pw),
    "at least one"
  )
  testthat::expect_error(
    project_update(pid = 1, name = "", url = url, un = un, pw = pw),
    "non-empty"
  )
  testthat::expect_error(
    project_update(pid = 1, archived = "yes", url = url, un = un, pw = pw),
    "TRUE or FALSE"
  )
  testthat::expect_error(
    project_update(pid = 1, name = "x", url = "", un = un, pw = pw),
    "Missing ODK Central"
  )
})

# usethis::use_r("project_update")  # nolint
