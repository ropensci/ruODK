test_that("submission_list works", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  sl <- submission_list(
    get_test_pid(),
    get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  fl <- form_list(
    get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  # submission_list returns a tibble
  testthat::expect_equal(class(sl), c("tbl_df", "tbl", "data.frame"))

  # https://github.com/ropensci/ruODK/issues/138
  # review_state was incorrectly picked up by mutate_at looking for "_at" dates
  testthat::expect_equal(class(sl$review_state), "character")

  # Submission attributes are the tibble's columns
  cn <- c(
    "instance_id",
    "submitter_id",
    "device_id",
    "created_at",
    "updated_at",
    "review_state",
    "user_agent",
    "submitter_id_2",
    "submitter_type",
    "submitter_display_name",
    "submitter_created_at",
    "submitter_updated_at",
    "submitter_deleted_at",
    "current_version"
  )
  testthat::expect_equal(names(sl), cn)
  # testthat::expect_equal(class(sl$review_state), "logical")
  purrr::map(
    cn,
    ~ testthat::expect_true(
      . %in% names(sl),
      label = glue::glue("Column {.} in submission_list")
    )
  )

  # Number of submissions (rows) is same as advertised in form_list
  form_list_nsub <- fl %>%
    dplyr::filter(fid == get_test_fid()) %>%
    magrittr::extract2("submissions") %>%
    as.numeric()
  testthat::expect_equal(nrow(sl), form_list_nsub)
})

# usethis::use_r("submission_list") # nolint
