test_that("submission_get works", {
  sl <- submission_list(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  sub <- submission_get(
    sl$instance_id[[1]],
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )

  # submission_detail returns a tibble
  testthat::expect_equal(class(sub), "list")


  # The details for one submission return exactly one row
  testthat::expect_equal(length(sub), 15)

  # The columns are metadata, plus the submission data in column 'xml`
  # names(sub)
  cn <- c(
    "meta", "encounter_start_datetime", "reporter", "device_id", "location",
    "habitat", "vegetation_stratum", "vegetation_stratum", "perimeter",
    "taxon_encounter", "taxon_encounter", "taxon_encounter", "taxon_encounter",
    "taxon_encounter", "encounter_end_datetime"
  )
  testthat::expect_equal(names(sub), cn)
})


# Tests code
# usethis::edit_file("R/submission_get.R")
