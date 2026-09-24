test_that("entitylist_property_delete removes a Property", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  skip_if(
    semver_lt(get_test_odkc_version(), "2026.1"),
    message = "Property deletion needs ODK Central 2026.1"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  dname <- glue::glue(
    "ruodk_test_propdel_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  entitylist_create(name = dname)

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

  entitylist_property_create(did = dname, property = "circumference")

  r <- entitylist_property_delete(did = dname, property = "circumference")
  testthat::expect_equal(r$success, TRUE)

  ed <- entitylist_detail(did = dname)
  testthat::expect_false(
    "circumference" %in% purrr::map_chr(ed$properties, "name")
  )
})

test_that("entitylist_property_delete rejects a missing or empty property", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    entitylist_property_delete(
      did = "trees",
      property = "",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
})

# usethis::use_r("entitylist_property_delete")  # nolint
