local_uuid <- function() {
  hex <- function(n) {
    paste(sample(c(0:9, letters[1:6]), n, replace = TRUE), collapse = "")
  }
  paste0("uuid:", hex(8), "-", hex(4), "-4", hex(3), "-", hex(4), "-", hex(12))
}

test_that("attachment_delete clears uploaded bytes but keeps the slot", {
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
    "ruodk_attd_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(
    xml = paste0(
      '<h:html xmlns="http://www.w3.org/2002/xforms" ',
      'xmlns:h="http://www.w3.org/1999/xhtml">',
      "<h:head><h:title>ruODK test</h:title><model><instance>",
      glue::glue('<data id="{fid}" version="1">'),
      "<meta><instanceID/></meta><name/><photo/></data>",
      "</instance>",
      '<bind nodeset="/data/name" type="string"/>',
      '<bind nodeset="/data/photo" type="binary"/>',
      "</model></h:head>",
      "<h:body>",
      '<input ref="/data/name"><label>What is your name?</label></input>',
      '<upload ref="/data/photo"><label>Photo</label></upload>',
      "</h:body></h:html>"
    ),
    publish = TRUE
  )

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
      glue::glue('<data id="{fid}" version="1">'),
      glue::glue("<meta><instanceID>{iid}</instanceID></meta>"),
      "<name>Jo</name><photo>photo.jpg</photo></data>"
    )
  )

  path <- withr::local_tempfile(fileext = ".jpg")
  writeBin(charToRaw("fake-jpeg-bytes"), path)
  attachment_upload(iid = iid, fid = fid, filename = "photo.jpg", file = path)

  d <- attachment_delete(iid = iid, fid = fid, filename = "photo.jpg")
  testthat::expect_equal(d$success, TRUE)

  al <- attachment_list(iid, pid = get_test_pid(), fid = fid)
  testthat::expect_true("photo.jpg" %in% al$name)
  testthat::expect_false(al$exists[al$name == "photo.jpg"])
})

test_that("attachment_delete rejects missing input", {
  testthat::expect_error(
    attachment_delete(
      iid = "uuid:1",
      fid = "f",
      filename = "",
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single non-empty"
  )
})

# usethis::use_r("attachment_delete")  # nolint
