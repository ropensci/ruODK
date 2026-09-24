test_that("entity_geojson returns the Entity geometry", {
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
    "ruodk_test_geo_{format(Sys.time(), '%Y%m%d%H%M%S')}"
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

  entitylist_property_create(did = dname, property = "geometry")

  ec <- entity_create(
    did = dname,
    label = "Geo point",
    data = list("geometry" = "-33.2 115.0 0 0")
  )

  g <- entity_geojson(did = dname, eid = ec$uuid)
  testthat::expect_equal(g$type, "FeatureCollection")
  testthat::expect_gte(length(g$features), 1)

  entity_delete(did = dname, eid = ec$uuid)
})

test_that("entity_geojson rejects a missing Entity UUID", {
  testthat::expect_error(
    entity_geojson(
      did = "trees",
      eid = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "Entity UUID"
  )
})

# usethis::use_r("entity_geojson")  # nolint
