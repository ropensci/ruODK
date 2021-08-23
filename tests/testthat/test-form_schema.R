test_that("form_schema v8 returns a tibble and ignores flatten and parse", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  vcr::use_cassette("test_form_schema0", {
    fs0 <- form_schema(
      flatten = FALSE,
      parse = FALSE,
      pid = get_test_pid(),
      fid = get_test_fid(),
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      odkc_version = get_test_odkc_version()
    )
  })
  testthat::expect_true(tibble::is_tibble(fs0))
})

test_that("form_schema works with unpublished draft forms", {
  vcr::use_cassette("test_form_schema1", {
    testthat::expect_message(
      form_schema(
        pid = get_test_pid(),
        fid = "Locations_draft",
        url = get_test_url(),
        un = get_test_un(),
        pw = get_test_pw(),
        odkc_version = get_test_odkc_version(),
        verbose = TRUE
      )
    )
  })

  vcr::use_cassette("test_form_schema2", {
    fs1 <- form_schema(
      flatten = FALSE,
      parse = FALSE,
      pid = get_test_pid(),
      fid = "Locations_draft",
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw(),
      odkc_version = get_test_odkc_version(),
      verbose = TRUE
    )
  })
  testthat::expect_true(tibble::is_tibble(fs1))
  testthat::expect_true(nrow(fs1) > 0)
})

# nolint start
# Tests for form schema v0.7
#   fs1 <- form_schema(
#     pid = get_test_pid(),
#     fid = get_test_fid(),
#     url = get_test_url(),
#     un = get_test_un(),
#     pw = get_test_pw(),
#     odkc_version = get_test_odkc_version()
#   )
#
#   # form_schema returns a nested list. There's nothing to change about that.
#   testthat::expect_equal(class(fs_nested), "list")
#   testthat::expect_equal(class(fs_flattened), "list")
#
#   # This assumes knowledge of that exact form being tested.
#   # First node: type "structure" (a field group) named "meta".
#   testthat::expect_equal(fs_nested[[1]]$type, "structure")
#   testthat::expect_equal(fs_nested[[1]]$name, "meta")
#   # The fact it contains children confirms that this is a field group.
#   testthat::expect_true("children" %in% names(fs_nested[[1]]))
#
#   # Next node: a "meta" field of type "string" capturing the  "instanceId".
#   # First child node of "meta": type "string", name "instanceId".
#   testthat::expect_equal(fs_nested[[1]]$children[[1]]$type, "string")
#   testthat::expect_equal(fs_nested[[1]]$children[[1]]$name, "instanceID")
#
#   # In the flattened version, the field's and it's ancestors' names are the
#   # components of "path".
#   testthat::expect_equal(fs_flattened[[1]]$path[[1]], "meta")
#   testthat::expect_equal(fs_flattened[[1]]$path[[2]], "instanceID")
#   testthat::expect_equal(fs_flattened[[1]]$type, "string")
#
#   # Last node: a "meta" field capturing the datetime of form completion
# testthat::expect_equal(fs_flattened[[length(fs_flattened)]]$type, "dateTime")
# testthat::expect_equal(fs_nested[[length(fs_nested)]]$type, "dateTime")
# })


# test_that("form_schema_parse works through form_schema", {
#   fsp <- form_schema(
#     parse = TRUE,
#     pid = get_test_pid(),
#     fid = get_test_fid(),
#     url = get_test_url(),
#     un = get_test_un(),
#     pw = get_test_pw(),
#     odkc_version = get_test_odkc_version()
#   )
#
#   testthat::expect_equal(class(fsp), c("tbl_df", "tbl", "data.frame"))
#   testthat::expect_true("encounter_start_datetime" %in% fsp$name)
#   testthat::expect_true("quadrat_photo" %in% fsp$name)
# })

# test_that("form_schema_parse warns on flatten and parsed", {
#   testthat::expect_warning(
#     fsp <- form_schema(
#       parse = TRUE,
#       flatten = TRUE,
#       pid = get_test_pid(),
#       fid = get_test_fid(),
#       url = get_test_url(),
#       un = get_test_un(),
#       pw = get_test_pw(),
#       odkc_version = get_test_odkc_version()
#     )
#   )
# })

# usethis::use_r("form_schema")
# nolint end
