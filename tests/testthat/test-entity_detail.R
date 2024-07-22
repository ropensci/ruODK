test_that("entity_detail works", {
  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  el <- entitylist_list()

  # Entity List name (dataset ID)
  did <- el$name[1]

  # All Entities of Entity List
  en <- entity_list(did = el$name[1])

  # Entity detail
  ed <- entity_detail(did = el$name[1], eid = en$uuid[1])

  cn <- c(
    "uuid",
    "creator_id",
    "conflict",
    "created_at",
    "updated_at",
    "deleted_at",
    "current_version"
    # not unfolded:
    # "current_version_created_at",
    # "current_version_current",
    # "current_version_label",
    # "current_version_creator_id",
    # "current_version_user_agent",
    # "current_version_version",
    # "current_version_base_version",
    # "current_version_conflicting_properties"
  )
  testthat::expect_equal(cn, names(ed))

  # The UUID of the first Entity
  eid <- en$uuid[1]
  testthat::expect_is(eid, "character")

  # The current version of the first Entity
  ev <- en$current_version_version[1]
  testthat::expect_is(ev, "integer")
})

test_that("entity_detail errors if did is missing", {
  testthat::expect_error(
    entity_detail()
  )
})

test_that("entity_detail warns if odkc_version too low", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
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

  # Entity List name (dataset ID)
  did <- el$name[1]

  # All Entities of Entity List
  en <- entity_list(did = el$name[1])

  # Entity detail
  ed <- entity_detail(did = el$name[1], eid = en$uuid[1])

  # Expect error with missing eid
  testthat::expect_error(
    entity_detail(did = el$name[1])
  )
})


# usethis::use_r("entity_detail")  # nolint
