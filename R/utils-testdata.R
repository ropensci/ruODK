#' Build test data for ruODK's test suite.
#'
#' Internal helpers that build random UUIDs, minimal valid XForms form
#' definitions, and matching Submission XML.
#' Not part of the public API.
#'
#' @param fid The form ID to use in the form definition.
#' @param photo Whether the form holds a binary photo upload field.
#' @param iid The Submission `instanceID`.
#' @param deprecated_id An optional replaced version's `instanceID`.
#' @param name The value of the name field.
#' @return `ru_uuid()` returns a random UUID with `uuid:` prefix.
#'   `ru_test_form_xml()` and `ru_test_submission_xml()` return XML as a
#'   single string.
#' @keywords internal
#' @name ru_testdata
NULL

#' @rdname ru_testdata
ru_uuid <- function() {
  hex <- function(n) {
    paste(sample(c(0:9, letters[1:6]), n, replace = TRUE), collapse = "")
  }
  paste0("uuid:", hex(8), "-", hex(4), "-4", hex(3), "-", hex(4), "-", hex(12))
}

#' @rdname ru_testdata
ru_test_form_xml <- function(fid, photo = FALSE) {
  photo_fields <- if (photo) "<name/><photo/>" else "<name/>"
  photo_bind <- if (photo) {
    '<bind nodeset="/data/photo" type="binary"/>'
  } else {
    ""
  }
  photo_body <- if (photo) {
    '<upload ref="/data/photo" mediatype="image/*"><label>Photo</label></upload>' # nolint
  } else {
    ""
  }
  paste0(
    '<h:html xmlns="http://www.w3.org/2002/xforms" ',
    'xmlns:h="http://www.w3.org/1999/xhtml" ',
    'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ',
    'xmlns:jr="http://openrosa.org/javarosa">',
    "<h:head><h:title>ruODK test</h:title><model><instance>",
    glue::glue('<data id="{fid}" version="1">'),
    "<meta><instanceID/></meta>",
    photo_fields,
    "</data>",
    "</instance>",
    '<bind nodeset="/data/meta/instanceID" type="string" readonly="true()" ',
    'calculate="concat(\'uuid:\', uuid())"/>',
    '<bind nodeset="/data/name" type="string"/>',
    photo_bind,
    "</model></h:head>",
    "<h:body>",
    '<input ref="/data/name"><label>What is your name?</label></input>',
    photo_body,
    "</h:body></h:html>"
  )
}

#' @rdname ru_testdata
ru_test_submission_xml <- function(
  fid,
  iid,
  deprecated_id = NULL,
  photo = FALSE,
  name = "Jo"
) {
  meta <- glue::glue("<meta><instanceID>{iid}</instanceID>")
  if (!is.null(deprecated_id)) {
    meta <- paste0(
      meta,
      glue::glue("<deprecatedID>{deprecated_id}</deprecatedID>")
    )
  }
  photo_el <- if (photo) "<photo>photo.jpg</photo>" else ""
  paste0(
    glue::glue('<data id="{fid}" version="1">'),
    meta,
    "</meta>",
    glue::glue("<name>{name}</name>"),
    photo_el,
    "</data>"
  )
}

# usethis::use_test("ru_testdata")  # nolint
