test_that("entitylist_create creates an Entity List", {
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

  dname <- glue::glue(
    "ruodk_test_el_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()

  el <- entitylist_create(name = dname)

  # Best-effort cleanup: dataset delete needs Central 2026.1, so older
  # servers answer 404 and try() keeps teardown quiet.
  withr::defer(
    try(
      httr::DELETE(
        paste0(
          get_test_url(),
          "/v1/projects/",
          get_test_pid(),
          "/datasets/",
          dname
        ),
        httr::authenticate(get_test_un(), get_test_pw())
      ),
      silent = TRUE
    )
  )

  testthat::expect_equal(el$name, dname)
  testthat::expect_equal(
    as.character(el$project_id),
    as.character(get_test_pid())
  )
  testthat::expect_equal(el$approval_required, FALSE)

  # A duplicate name is rejected by Central.
  testthat::expect_error(entitylist_create(name = dname))

  # The new Entity List is listed with the same name.
  ell <- entitylist_list()
  testthat::expect_true(dname %in% ell$name)
})

test_that("entitylist_create rejects a missing or invalid name", {
  # Dummy credentials: validation runs before any request is sent.
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    entitylist_create(name = "", url = url, un = un, pw = pw),
    "non-empty"
  )
  testthat::expect_error(
    entitylist_create(name = c("a", "b"), url = url, un = un, pw = pw),
    "non-empty"
  )
  testthat::expect_error(
    entitylist_create(name = ".hidden", url = url, un = un, pw = pw),
    "must not start"
  )
  testthat::expect_error(
    entitylist_create(name = "__reserved", url = url, un = un, pw = pw),
    "must not start"
  )
})

# usethis::use_r("entitylist_create")  # nolint
