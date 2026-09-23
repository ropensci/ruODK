#' Create a new Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' When creating a Form, the only required data is the actual XForms XML
#' or XLSForm itself.
#'
#' Forms will by default be created in Draft state, accessible under
#' `/projects/.../forms/.../draft`.
#' The Form itself will not have a public XML definition, and will not
#' appear for download onto mobile devices.
#' You will need to publish the Form to finalize it for data collection.
#' To disable this behaviour, and force the new Form to be immediately
#' ready, pass `publish = TRUE`.
#'
#' The API will check the XML's structure in order to extract the
#' information it needs about it, but ODK Central does not run
#' comprehensive validation on the full contents of the XML.
#' ODK Validate finds problems in the Form before upload.
#' Publish the Draft after the Form passes validation.
#'
#' @template param-pid
#' @param xml (character) The XForms XML definition as a single string.
#'   Exactly one of `xml` and `file` must be given.
#'   Default: `NULL`.
#' @param file (character) Path to a local `.xml`, `.xls` or `.xlsx` file
#'   holding the Form definition.
#'   Exactly one of `xml` and `file` must be given.
#'   Default: `NULL`.
#' @param publish (lgl) If `TRUE`, the Form skips the Draft state and is
#'   published immediately.
#'   Default: `FALSE`.
#' @param ignore_warnings (lgl) If `TRUE`, the Form is created even if the
#'   XLSForm conversion results in warnings.
#'   Conversion errors always fail the request.
#'   Only used for `.xls`/`.xlsx` uploads.
#'   Default: `FALSE`.
#' @param xls_form_id_fallback (character) The form ID to use if an
#'   uploaded spreadsheet does not specify one.
#'   Sent as the `X-XlsForm-FormId-Fallback` header.
#'   Only used for `.xls`/`.xlsx` uploads.
#'   Default: `NULL` (no header sent).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the new Form's metadata as per the ODK Central API
#'   docs.
#'   Top level list elements are renamed from ODK's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#creating-a-new-form}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' xml <- paste0(
#'   '<h:html xmlns="http://www.w3.org/2002/xforms" ',
#'   'xmlns:h="http://www.w3.org/1999/xhtml">',
#'   "<h:head><h:title>Simple</h:title><model><instance>",
#'   '<data id="simple"><meta><instanceID/></meta><name/></data>',
#'   "</instance>",
#'   '<bind nodeset="/data/meta/instanceID" type="string" readonly="true()" ',
#'   'calculate="concat(\'uuid:\', uuid())"/>',
#'   '<bind nodeset="/data/name" type="string"/>',
#'   "</model></h:head>",
#'   '<h:body><input ref="/data/name"><label>Name</label></input></h:body>',
#'   "</h:html>"
#' )
#'
#' f <- form_create(xml = xml, publish = TRUE)
#'
#' f$xml_form_id
#' # > "simple"
#' }
form_create <- function(
  pid = get_default_pid(),
  xml = NULL,
  file = NULL,
  publish = FALSE,
  ignore_warnings = FALSE,
  xls_form_id_fallback = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid)

  has_xml <- is.character(xml) &&
    length(xml) == 1L &&
    !is.na(xml) &&
    nzchar(xml)
  has_file <- is.character(file) && length(file) == 1L && !is.na(file)
  if (has_xml == has_file) {
    ru_msg_abort("Exactly one of 'xml' and 'file' must be given.")
  }

  content_type <- "application/xml"
  body <- NULL
  extra_headers <- list()
  if (has_file) {
    if (!file.exists(file)) {
      ru_msg_abort(glue::glue("File not found: {file}"))
    }
    ext <- tolower(tools::file_ext(file))
    if (ext == "xml") {
      body <- paste(readLines(file, warn = FALSE), collapse = "\n")
    } else if (ext %in% c("xls", "xlsx")) {
      content_type <- if (ext == "xlsx") {
        paste0(
          "application/vnd.openxmlformats-officedocument.",
          "spreadsheetml.sheet"
        )
      } else {
        "application/vnd.ms-excel"
      }
      body <- readBin(file, "raw", file.info(file)$size)
      if (!is.null(xls_form_id_fallback)) {
        extra_headers[["X-XlsForm-FormId-Fallback"]] <-
          xls_form_id_fallback
      }
    } else {
      ru_msg_abort("file must end in '.xml', '.xls' or '.xlsx'.")
    }
  } else {
    body <- xml
  }

  query <- list()
  if (isTRUE(publish)) {
    query$publish <- "true"
  }
  if (isTRUE(ignore_warnings)) {
    query$ignoreWarnings <- "true"
  }

  httr::RETRY(
    "POST",
    httr::modify_url(
      url,
      path = glue::glue("v1/projects/{pid}/forms"),
      query = query
    ),
    httr::add_headers(
      .headers = c(
        "Accept" = "application/json",
        "Content-Type" = content_type,
        unlist(extra_headers)
      )
    ),
    body = body,
    encode = "raw",
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("form_create")  # nolint
