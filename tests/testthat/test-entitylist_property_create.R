test_that("entitylist_property_create adds a Property", {
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
    "ruodk_test_prop_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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

  r <- entitylist_property_create(did = dname, property = "circumference")
  testthat::expect_equal(r$success, TRUE)

  # A duplicate Property is rejected by Central.
  testthat::expect_error(
    entitylist_property_create(did = dname, property = "circumference")
  )

  # The new Property is listed in the Entity List details.
  ed <- entitylist_detail(did = dname)
  testthat::expect_true(
    "circumference" %in% purrr::map_chr(ed$properties, "name")
  )
})

test_that("entitylist_property_create rejects a missing or empty property", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    entitylist_property_create(
      did = "trees",
      property = "",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
  testthat::expect_error(
    entitylist_property_create(
      did = "",
      property = "x",
      url = url,
      un = un,
      pw = pw
    ),
    "Entity List"
  )
})

# usethis::use_r("entitylist_property_create")  # nolint
