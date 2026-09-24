test_that("entitylist_trash_download exports a deleted Entity List", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  skip_if(
    semver_lt(get_test_odkc_version(), "2026.1"),
    message = "Trash download needs ODK Central 2026.1"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  dname <- glue::glue(
    "ruodk_test_trash_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  entitylist_create(name = dname)
  entitylist_property_create(did = dname, property = "note")
  entity_create(did = dname, label = "Trash me", data = list("note" = "x"))
  entitylist_delete(did = dname)

  trash <- entitylist_list(deleted = TRUE)
  testthat::expect_true(dname %in% trash$name)
  numeric_id <- trash$id[trash$name == dname][[1]]

  dl <- entitylist_trash_download(dataset_id = numeric_id)
  testthat::expect_equal(dl$http_status, 200)
  testthat::expect_true(file.exists(dl$downloaded_to))
})

test_that("entitylist_trash_download rejects a missing Dataset ID", {
  testthat::expect_error(
    entitylist_trash_download(
      dataset_id = NA,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single Dataset ID"
  )
})

# usethis::use_r("entitylist_trash_download")  # nolint
