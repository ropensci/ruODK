# Helpers for Form version tests (#129, #161).
#
# Builds a form whose field moves out of a group between two published
# versions: v1 holds the field at /mygroup/myfield, v2 at /myfield.
# Moving a field is a structural change, so drafts need
# `ignore_warnings = TRUE`. Test files source this helper automatically.

versioned_grouped_xml <- function(fid, version) {
  paste0(
    '<h:html xmlns="http://www.w3.org/2002/xforms" ',
    'xmlns:h="http://www.w3.org/1999/xhtml" ',
    'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ',
    'xmlns:jr="http://openrosa.org/javarosa">',
    "<h:head><h:title>versions</h:title><model><instance>",
    glue::glue('<data id="{fid}" version="{version}">'),
    "<meta><instanceID/></meta>",
    "<mygroup><myfield/></mygroup>",
    "</data></instance>",
    '<bind nodeset="/data/meta/instanceID" type="string" readonly="true()" ',
    'calculate="concat(\'uuid:\', uuid())"/>',
    '<bind nodeset="/data/mygroup/myfield" type="string"/>',
    "</model></h:head><h:body>",
    '<group ref="/data/mygroup"><label>Group</label>',
    '<input ref="/data/mygroup/myfield"><label>My field</label></input>',
    "</group></h:body></h:html>"
  )
}

versioned_ungrouped_xml <- function(fid, version) {
  paste0(
    '<h:html xmlns="http://www.w3.org/2002/xforms" ',
    'xmlns:h="http://www.w3.org/1999/xhtml" ',
    'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ',
    'xmlns:jr="http://openrosa.org/javarosa">',
    "<h:head><h:title>versions</h:title><model><instance>",
    glue::glue('<data id="{fid}" version="{version}">'),
    "<meta><instanceID/></meta>",
    "<myfield/>",
    "</data></instance>",
    '<bind nodeset="/data/meta/instanceID" type="string" readonly="true()" ',
    'calculate="concat(\'uuid:\', uuid())"/>',
    '<bind nodeset="/data/myfield" type="string"/>',
    "</model></h:head><h:body>",
    '<input ref="/data/myfield"><label>My field</label></input>',
    "</h:body></h:html>"
  )
}

versioned_post_submission <- function(fid, version, iid, field_xml) {
  body <- glue::glue(
    '<data id="{fid}" version="{version}">',
    "<meta><instanceID>{iid}</instanceID></meta>{field_xml}</data>"
  ) |>
    as.character()
  r <- httr::POST(
    paste0(
      get_test_url(),
      "/v1/projects/",
      get_test_pid(),
      "/forms/",
      fid,
      "/submissions"
    ),
    httr::authenticate(get_test_un(), get_test_pw()),
    httr::add_headers("Content-Type" = "application/xml"),
    body = body
  )
  testthat::expect_equal(httr::status_code(r), 200)
  invisible(r)
}

# Create a two-version form, optionally with one submission per version.
# Returns list(fid, iid1, iid2, val_v1, val_v2) and deletes the form on exit.
setup_moved_field_form <- function(submit = TRUE) {
  fid <- glue::glue(
    "ruodk_ver_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  val_v1 <- paste0("value-v1-", fid)
  val_v2 <- paste0("value-v2-", fid)

  form_create(
    pid = get_test_pid(),
    xml = versioned_grouped_xml(fid, "grp1"),
    publish = TRUE,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  iid1 <- ru_uuid()
  if (isTRUE(submit)) {
    versioned_post_submission(
      fid,
      "grp1",
      iid1,
      glue::glue("<mygroup><myfield>{val_v1}</myfield></mygroup>")
    )
  }

  form_draft_create(
    pid = get_test_pid(),
    fid = fid,
    xml = versioned_ungrouped_xml(fid, "grp2"),
    ignore_warnings = TRUE,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  form_draft_publish(
    pid = get_test_pid(),
    fid = fid,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  iid2 <- ru_uuid()
  if (isTRUE(submit)) {
    versioned_post_submission(
      fid,
      "grp2",
      iid2,
      glue::glue("<myfield>{val_v2}</myfield>")
    )
  }

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    ),
    envir = parent.frame()
  )
  list(fid = fid, iid1 = iid1, iid2 = iid2, val_v1 = val_v1, val_v2 = val_v2)
}

flatten_test_chars <- function(x) {
  if (is.character(x)) {
    return(x)
  }
  if (is.list(x)) {
    return(unlist(lapply(x, flatten_test_chars)))
  }
  character(0)
}
