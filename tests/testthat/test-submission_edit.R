test_that("submission_edit edits a field and comments", {
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

  fid <- glue::glue(
    "ruodk_sedit_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    form_delete(
      fid = fid,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  iid <- ru_uuid()
  submission_create(
    fid = fid,
    xml = ru_test_submission_xml(fid, iid)
  )

  se <- submission_edit(
    iid = iid,
    fid = fid,
    field = "name",
    value = "Jo updated",
    comment = "Fixed the name."
  )
  testthat::expect_true(is.list(se))
  testthat::expect_true(all(c("update", "comment") %in% names(se)))

  # The edit created a new version
  sv <- submission_versions(iid = iid, fid = fid)
  testthat::expect_true(nrow(sv) >= 2)

  # The comment landed on the Submission
  cl <- submission_comment_list(iid = iid, fid = fid)
  testthat::expect_true("Fixed the name." %in% cl$body)
})

test_that("submission_edit rejects bad input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    submission_edit(
      iid = "uuid:1",
      fid = "f",
      field = "",
      value = "x",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
  testthat::expect_error(
    submission_edit(
      iid = "uuid:1",
      fid = "f",
      field = "name",
      value = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "single non-missing"
  )
  testthat::expect_error(
    submission_edit(
      iid = "uuid:1",
      fid = "",
      field = "name",
      value = "x",
      url = url,
      un = un,
      pw = pw
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_edit")  # nolint
