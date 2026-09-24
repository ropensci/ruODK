test_that("entity_bulk_delete and entity_bulk_restore round-trip", {
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
    "ruodk_test_bulk_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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

  entitylist_property_create(did = dname, property = "note")

  e1 <- entity_create(
    did = dname,
    label = "Bulk one",
    data = list("note" = "first")
  )
  e2 <- entity_create(
    did = dname,
    label = "Bulk two",
    data = list("note" = "second")
  )

  d <- entity_bulk_delete(did = dname, eids = c(e1$uuid, e2$uuid))
  testthat::expect_equal(d$count, 2)

  r <- entity_bulk_restore(did = dname, eids = c(e1$uuid, e2$uuid))
  testthat::expect_equal(r$count, 2)

  ed <- entity_detail(did = dname, eid = e1$uuid)
  testthat::expect_equal(ed$uuid, e1$uuid)

  entity_bulk_delete(did = dname, eids = c(e1$uuid, e2$uuid))
})

test_that("entity_bulk_delete rejects missing UUIDs", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    entity_bulk_delete(did = "trees", eids = c(), url = url, un = un, pw = pw),
    "one or more"
  )
  testthat::expect_error(
    entity_bulk_restore(
      did = "trees",
      eids = c(NA_character_),
      url = url,
      un = un,
      pw = pw
    ),
    "one or more"
  )
})

# usethis::use_r("entity_bulk_delete")  # nolint
