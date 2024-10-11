test_that("form_list works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  fl <- form_list(
    get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_equal(class(fl), c("tbl_df", "tbl", "data.frame"))
  cn <- c(
    "project_id", "xml_form_id", "state", "enketo_id", "enketo_once_id",
    "created_at", "updated_at", "key_id", "version", "hash",
    "sha", "sha256", "draft_token", "published_at", "name",
    "submissions", "entity_related", "review_states_received",
    "review_states_has_issues", "review_states_edited", "last_submission",
    "excel_content_type", "public_links", "created_by_id", "created_by_type",
    "created_by_display_name", "created_by_created_at",
    "created_by_updated_at", "created_by_deleted_at", "fid"
  )
  testthat::expect_equal(names(fl), cn)

  # Testing #86 form_list should work with draft forms present.
  # The above call to form_list worked so we test here that
  # the test forms contain a draft form.
  # Update: https://github.com/ropensci/ruODK/issues/119
  # Draft forms, and any forms from older Central versions
  # have published_at = NA.
  fl %>%
    dplyr::filter(is.na(published_at)) %>%
    nrow() %>%
    testthat::expect_gt(0)
})

# usethis::use_r("form_list") # nolint
