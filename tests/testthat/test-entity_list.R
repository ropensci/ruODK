test_that("entity_list works", {
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
    "current_version_created_at",
    "current_version_branch_id",
    "current_version_trunk_version",
    "current_version_branch_base_version"
  )

  testthat::expect_equal(names(en), cn)
})

test_that("entity_list lists deleted Entities", {
  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  el <- entitylist_list()
  en_deleted <- entity_list(did = el$name[1], deleted = TRUE)
  testthat::expect_s3_class(en_deleted, "tbl_df")
})

test_that("entity_list warns if odkc_version too low", {
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

  # Unknown Entity Lists fail with 404, after the version gate warning
  testthat::expect_warning(
    testthat::expect_error(
      entity_list(did = "no-such-list", odkc_version = "2022.2")
    ),
    "supported from v2022.3"
  )
})

test_that("entity_list returns documented columns for empty Datasets", {
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
    "ruodk_test_empty_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  entitylist_create(name = dname)

  withr::defer(
    entitylist_delete(
      did = dname,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  # An empty Dataset answers `[]`: no rows, but the documented columns
  en <- entity_list(did = dname)
  testthat::expect_s3_class(en, "tbl_df")
  testthat::expect_equal(nrow(en), 0)

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
    "current_version_created_at",
    "current_version_branch_id",
    "current_version_trunk_version",
    "current_version_branch_base_version"
  )
  testthat::expect_equal(names(en), cn)

  # Empty and non-empty results combine row-wise
  el <- entitylist_list()
  en_full <- entity_list(did = el$name[el$name != dname][1])
  testthat::expect_equal(nrow(dplyr::bind_rows(en_full, en)), nrow(en_full))
})

# usethis::use_r("entity_list")  # nolint

# usethis::use_r("entity_list")  # nolint
