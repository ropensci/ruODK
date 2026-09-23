local_uuid <- function() {
  hex <- function(n) {
    paste(sample(c(0:9, letters[1:6]), n, replace = TRUE), collapse = "")
  }
  paste0("uuid:", hex(8), "-", hex(4), "-4", hex(3), "-", hex(4), "-", hex(12))
}

local_write_form_xml <- function(fid) {
  paste0(
    '<h:html xmlns="http://www.w3.org/2002/xforms" ',
    'xmlns:h="http://www.w3.org/1999/xhtml" ',
    'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ',
    'xmlns:jr="http://openrosa.org/javarosa">',
    "<h:head><h:title>ruODK test</h:title><model><instance>",
    glue::glue('<data id="{fid}" version="1">'),
    "<meta><instanceID/></meta><name/><photo/></data>",
    "</instance>",
    '<bind nodeset="/data/meta/instanceID" type="string" readonly="true()" ',
    'calculate="concat(\'uuid:\', uuid())"/>',
    '<bind nodeset="/data/name" type="string"/>',
    '<bind nodeset="/data/photo" type="binary"/>',
    "</model></h:head>",
    "<h:body>",
    '<input ref="/data/name"><label>What is your name?</label></input>',
    '<upload ref="/data/photo" mediatype="image/*"><label>Photo</label></upload>', # nolint
    "</h:body></h:html>"
  )
}

local_write_submission_xml <- function(fid, iid, deprecated_id = NULL) {
  meta <- glue::glue("<meta><instanceID>{iid}</instanceID>")
  if (!is.null(deprecated_id)) {
    meta <- paste0(
      meta,
      glue::glue("<deprecatedID>{deprecated_id}</deprecatedID>")
    ) # nolint
  }
  paste0(
    glue::glue('<data id="{fid}" version="1">'),
    meta,
    "</meta><name>Jo</name><photo>photo.jpg</photo></data>"
  )
}

test_that("submission_create creates a Submission", {
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
    "ruodk_subc_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = local_write_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  iid <- local_uuid()
  s <- submission_create(
    fid = fid,
    xml = local_write_submission_xml(fid, iid)
  )

  testthat::expect_equal(s$instance_id, iid)

  # A duplicate instanceID is rejected by Central.
  testthat::expect_error(
    submission_create(fid = fid, xml = local_write_submission_xml(fid, iid))
  )

  # The new Submission is listed with the same instanceID.
  sl <- submission_list(pid = get_test_pid(), fid = fid)
  testthat::expect_true(iid %in% sl$instance_id)
})

test_that("submission_create rejects missing input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    submission_create(fid = "some_form", url = url, un = un, pw = pw),
    "single non-empty"
  )
  testthat::expect_error(
    submission_create(fid = "some_form", xml = "", url = url, un = un, pw = pw),
    "single non-empty"
  )
  testthat::expect_error(
    submission_create(xml = "<data/>", url = "", un = un, pw = pw),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_create")  # nolint
