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
    "created_at",
    "creator_id",
    "updated_at",
    "deleted_at",
    "conflict",
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

test_that("entitylist_detail errors if did is missing", {
  testthat::expect_error(
    entitylist_detail()
  )
})

test_that("entitylist_detail warns if odkc_version too low", {
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

  ds <- entitylist_list()
  did <- ds$name[1]

  ds1 <- entitylist_detail(did = did)

  testthat::expect_warning(
    ds1 <- entitylist_detail(did = did, odkc_version = "1.5.3")
  )
})


# usethis::use_e("entity_detail")  # nolint