test_that("entity_restore restores a deleted Entity", {
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

  el <- entitylist_list()
  did <- el$name[1]

  lab <- glue::glue(
    "Entity restored by ruODK test on {Sys.time()}"
  ) |>
    as.character()
  ec <- entity_create(
    did = did,
    label = lab,
    data = list("status" = "needs_followup")
  )

  entity_delete(did = did, eid = ec$uuid)

  r <- entity_restore(did = did, eid = ec$uuid)
  testthat::expect_equal(r$success, TRUE)

  ed <- entity_detail(did = did, eid = ec$uuid)
  testthat::expect_equal(ed$uuid, ec$uuid)

  entity_delete(did = did, eid = ec$uuid)
})

test_that("entity_restore rejects a missing Entity UUID", {
  testthat::expect_error(
    entity_restore(
      did = "trees",
      eid = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "Entity UUID"
  )
})

# usethis::use_r("entity_restore")  # nolint
