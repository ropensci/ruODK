test_that("entity_list works", {
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
  did <- el$name[1]
  en <- entity_list(did = el$name[1])
  eid <- en$uuid[1]

  testthat::expect_s3_class(en, "tbl_df")

  cn <- c(
    "uuid",
    "creator_id",
    "created_at",
    "updated_at",
    "deleted_at",
    "current_version_current",
    "current_version_label",
    "current_version_creator_id",
    "current_version_user_agent",
    "current_version_version",
    "current_version_base_version",
    "current_version_conflicting_properties",
    "current_version_created_at"
  )

  testthat::expect_equal(names(en), cn)
})

# usethis::use_r("entity_list")  # nolint
