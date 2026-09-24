test_that("project_replace replaces top-level metadata", {
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

  r <- project_replace(
    pid = p$id,
    name = paste0(pname, " replaced"),
    description = "Replaced by ruODK test.",
    archived = FALSE,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(r$name, paste0(pname, " replaced"))
  testthat::expect_equal(r$description, "Replaced by ruODK test.")
  testthat::expect_equal(r$archived, FALSE)
})

test_that("project_replace rejects missing or invalid input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    project_replace(pid = 1, name = "x", url = "", un = un, pw = pw),
    "Missing ODK Central"
  )
  testthat::expect_error(
    project_replace(pid = 1, name = "", url = url, un = un, pw = pw),
    "non-empty"
  )
  testthat::expect_error(
    project_replace(
      pid = 1,
      name = "x",
      archived = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "TRUE or FALSE"
  )
})

# usethis::use_r("project_replace")  # nolint
