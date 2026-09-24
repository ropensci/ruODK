test_that("submission_version_geojson returns version geodata", {
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

  fid <- glue::glue(
    "ruodk_vgeo_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid, geo = TRUE), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  iid <- ru_uuid()
  submission_create(
    fid = fid,
    xml = ru_test_submission_xml(fid, iid, geo = "-33.2 115.0 0 0")
  )

  g <- submission_version_geojson(iid = iid, fid = fid, vid = iid)
  testthat::expect_equal(g$type, "FeatureCollection")
  testthat::expect_gte(length(g$features), 1)
})

test_that("submission_version_geojson rejects a missing vid", {
  testthat::expect_error(
    submission_version_geojson(
      iid = "uuid:1",
      fid = "f",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# usethis::use_r("submission_version_geojson")  # nolint
