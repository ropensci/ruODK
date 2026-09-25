#' Edit one Submission field and leave a comment.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This convenience wrapper edits one field of a Submission and,
#' optionally, leaves a comment about the edit.
#' It downloads the current Submission XML, sets the field to the new
#' value, rotates the `deprecatedID` metadata node to the current
#' `instanceID`, assigns a new `instanceID`, uploads the result with
#' `submission_update()`, and posts the comment with
#' `submission_comment_create()`.
#' The new value is checked against the field type from `form_schema()`.
#'
#' @template param-iid
#' @param field (character) The XForms field to edit, e.g. `"name"` or
#'   `"/data/name"`.
#' @param value The new field value, coerced to a string.
#'   It must match the field type from `form_schema()`: integers for
#'   `"int"`, numbers for `"decimal"`, anything for `"string"`.
#' @param comment (character) A comment about the edit, posted with
#'   `submission_comment_create()`.
#'   Default: `NULL` (no comment posted).
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the `update` result from `submission_update()` and,
#'   if a comment was given, the `comment` result from
#'   `submission_comment_create()`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#updating-submission-data}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' sl <- submission_list()
#' iid <- sl$instance_id[[1]]
#'
#' se <- submission_edit(
#'   iid = iid,
#'   field = "name",
#'   value = "Jo updated",
#'   comment = "Fixed the name."
#' )
#'
#' se$update$current_version$instanceId
#' }
submission_edit <- function(
  iid,
  field,
  value,
  comment = NULL,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  if (
    !is.character(field) ||
      length(field) != 1L ||
      is.na(field) ||
      !nzchar(field)
  ) {
    ru_msg_abort("field must be a single non-empty character string.")
  }
  if (length(value) != 1L || is.na(value)) {
    ru_msg_abort("value must be a single non-missing value.")
  }
  if (!is.null(comment)) {
    if (
      !is.character(comment) ||
        length(comment) != 1L ||
        is.na(comment) ||
        !nzchar(comment)
    ) {
      ru_msg_abort("comment must be a single non-empty character string.")
    }
  }

  field_path <- paste0("/data/", sub("^/data/", "", field))

  # Check the value against the field type from the form schema
  fs <- form_schema(
    pid = pid,
    fid = fid,
    url = url,
    un = un,
    pw = pw,
    retries = retries
  )
  frow <- fs[fs$path == field_path | fs$name == sub("^/data/", "", field), ]
  if (nrow(frow) > 0 && !is.na(frow$type[[1]])) {
    ftype <- frow$type[[1]]
    if (ftype == "int" && is.na(suppressWarnings(as.integer(value)))) {
      ru_msg_abort(glue::glue(
        "Type mismatch, integer expected for field \"{field}\"."
      ))
    }
    if (ftype == "decimal" && is.na(suppressWarnings(as.numeric(value)))) {
      ru_msg_abort(glue::glue(
        "Type mismatch, number expected for field \"{field}\"."
      ))
    }
  }

  # Download the current Submission XML
  doc <- ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}.xml"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_xml()

  # Set the new field value
  target_node <- xml2::xml_find_first(doc, field_path)
  if (inherits(target_node, "xml_missing")) {
    ru_msg_abort(glue::glue("Field \"{field}\" not found in Submission."))
  }
  xml2::xml_text(target_node) <- as.character(value)

  # Rotate deprecatedID to the current instanceID, assign a new instanceID
  instance_id_node <- xml2::xml_find_first(doc, "/data/meta/instanceID")
  deprecated_id_node <- xml2::xml_find_first(doc, "/data/meta/deprecatedID")
  if (inherits(deprecated_id_node, "xml_missing")) {
    xml2::xml_add_sibling(instance_id_node, instance_id_node)
    xml2::xml_name(instance_id_node) <- "deprecatedID"
    instance_id_node <- xml2::xml_find_first(doc, "/data/meta/instanceID")
  } else {
    xml2::xml_text(deprecated_id_node) <- xml2::xml_text(instance_id_node)
  }
  xml2::xml_text(instance_id_node) <- ru_uuid()

  update <- submission_update(
    iid = iid,
    pid = pid,
    fid = fid,
    xml = as.character(doc),
    url = url,
    un = un,
    pw = pw,
    retries = retries
  )

  out <- list(update = update)
  if (!is.null(comment)) {
    out$comment <- submission_comment_create(
      iid = iid,
      body = comment,
      pid = pid,
      fid = fid,
      url = url,
      un = un,
      pw = pw,
      retries = retries
    )
  }
  out
}

# usethis::use_test("submission_edit")  # nolint
