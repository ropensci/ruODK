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
  testthat::expect_error(
    submission_edit(
      iid = "uuid:1",
      fid = "f",
      field = "name",
      value = "x",
      comment = "",
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
})

typed_form_xml <- function(fid) {
  paste0(
    '<h:html xmlns="http://www.w3.org/2002/xforms" ',
    'xmlns:h="http://www.w3.org/1999/xhtml" ',
    'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ',
    'xmlns:jr="http://openrosa.org/javarosa">',
    "<h:head><h:title>typed</h:title><model><instance>",
    glue::glue('<data id="{fid}" version="1">'),
    "<meta><instanceID/></meta>",
    "<age/><height/>",
    "</data></instance>",
    '<bind nodeset="/data/meta/instanceID" type="string" readonly="true()" ',
    'calculate="concat(\'uuid:\', uuid())"/>',
    '<bind nodeset="/data/age" type="int"/>',
    '<bind nodeset="/data/height" type="decimal"/>',
    "</model></h:head><h:body>",
    '<input ref="/data/age"><label>Age</label></input>',
    '<input ref="/data/height"><label>Height</label></input>',
    "</h:body></h:html>"
  )
}

typed_submission_xml <- function(fid, iid, age = "3", height = "1.5") {
  paste0(
    glue::glue('<data id="{fid}" version="1">'),
    glue::glue("<meta><instanceID>{iid}</instanceID></meta>"),
    glue::glue("<age>{age}</age><height>{height}</height>"),
    "</data>"
  )
}

test_that("submission_edit checks field types", {
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
    "ruodk_styped_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = typed_form_xml(fid), publish = TRUE)

  withr::defer(
    form_delete(
      fid = fid,
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    )
  )

  iid <- ru_uuid()
  submission_create(fid = fid, xml = typed_submission_xml(fid, iid))

  # Integers reject non-integer values
  testthat::expect_error(
    submission_edit(iid = iid, fid = fid, field = "age", value = "old"),
    "integer expected"
  )

  # Decimals reject non-numeric values
  testthat::expect_error(
    submission_edit(iid = iid, fid = fid, field = "height", value = "tall"),
    "number expected"
  )

  # Unknown fields are rejected after downloading the Submission XML
  testthat::expect_error(
    submission_edit(
      iid = iid,
      fid = fid,
      field = "no_such_field",
      value = "x"
    ),
    "not found in Submission"
  )

  # A first edit rotates instanceID into deprecatedID
  se1 <- submission_edit(iid = iid, fid = fid, field = "age", value = "4")
  testthat::expect_true(is.list(se1))

  # A second edit finds deprecatedID already present
  se2 <- submission_edit(iid = iid, fid = fid, field = "age", value = "5")
  testthat::expect_true(is.list(se2))

  sv <- submission_versions(iid = iid, fid = fid)
  testthat::expect_gte(nrow(sv), 3)
})

# usethis::use_r("submission_edit")  # nolint
