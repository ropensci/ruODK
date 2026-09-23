local_uuid <- function() {
  hex <- function(n) {
    paste(sample(c(0:9, letters[1:6]), n, replace = TRUE), collapse = "")
  }
  paste0("uuid:", hex(8), "-", hex(4), "-4", hex(3), "-", hex(4), "-", hex(12))
}

local_delete_form_xml <- function(fid) {
  paste0(
    '<h:html xmlns="http://www.w3.org/2002/xforms" ',
    'xmlns:h="http://www.w3.org/1999/xhtml">',
    "<h:head><h:title>ruODK test</h:title><model><instance>",
    glue::glue('<data id="{fid}"><meta><instanceID/></meta><name/></data>'),
    "</instance>",
    '<bind nodeset="/data/name" type="string"/>',
    "</model></h:head>",
    "<h:body>",
    '<input ref="/data/name"><label>What is your name?</label></input>',
    "</h:body></h:html>"
  )
}

test_that("submission_delete soft-deletes a Submission", {
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
    "ruodk_subd_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = local_delete_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  iid <- local_uuid()
  submission_create(
    fid = fid,
    xml = paste0(
      glue::glue('<data id="{fid}">'),
      glue::glue("<meta><instanceID>{iid}</instanceID></meta>"),
      "<name>Jo</name></data>"
    )
  )

  d <- submission_delete(iid = iid, fid = fid)
  testthat::expect_equal(d$success, TRUE)

  # Deleting twice is rejected by Central.
  testthat::expect_error(submission_delete(iid = iid, fid = fid))

  submission_restore(iid = iid, fid = fid)
})

test_that("submission_delete rejects missing input", {
  testthat::expect_error(
    submission_delete(
      iid = "uuid:1",
      fid = "f",
      url = "",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_delete")  # nolint
