test_that("form_schema works", {
  fs_nested <- form_schema(
    flatten = FALSE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  fs_flattened <- form_schema(
    flatten = TRUE,
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  # form_schema returns a nested list. There's nothing to change about that.
  testthat::expect_equal(class(fs_nested), "list")
  testthat::expect_equal(class(fs_flattened), "list")

  # This assumes knowledge of that exact form being tested.
  # First node: type "structure" (a field group) named "meta".
  testthat::expect_equal(fs_nested[[1]]$type, "structure")
  testthat::expect_equal(fs_nested[[1]]$name, "meta")
  # The fact it contains children confirms that this is a field group.
  testthat::expect_true("children" %in% names(fs_nested[[1]]))

  # Next node: a "meta" field of type "string" capturing the  "instanceId".
  # First child node of "meta": type "string", name "instanceId".
  testthat::expect_equal(fs_nested[[1]]$children[[1]]$type, "string")
  testthat::expect_equal(fs_nested[[1]]$children[[1]]$name, "instanceID")

  # In the flattened version, the field's and it's ancestors' names are the
  # components of "path".
  testthat::expect_equal(fs_flattened[[1]]$path[[1]], "meta")
  testthat::expect_equal(fs_flattened[[1]]$path[[2]], "instanceID")
  testthat::expect_equal(fs_flattened[[1]]$type, "string")

  # Last node: a "meta" field capturing the datetime of form completion
  testthat::expect_equal(fs_flattened[[length(fs_flattened)]]$type, "dateTime")
  testthat::expect_equal(fs_nested[[length(fs_nested)]]$type, "dateTime")
})


# Tests code
# usethis::edit_file("R/form_schema.R")
