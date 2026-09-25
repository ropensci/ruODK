#' Create a Draft Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' POSTing here creates a new Draft Form on the given Form.
#' For the most part, it takes the same parameters as the Create Form
#' request: you can submit XML or Excel files, and you can provide
#' `ignore_warnings`.
#' Additionally, a call with neither `xml` nor `file` creates a Draft
#' Form with a copy of the published definition, if there is one.
#' This is useful to change Form Attachments without updating the Form
#' definition itself.
#' Even if a Draft exists, you can always replace it by calling this
#' function again.
#' The `xmlFormId` must exactly match that of the Form overall, or the
#' request is rejected.
#'
#' @template param-pid
#' @template param-fid
#' @param xml (character) The XForms XML definition as a single string.
#'   If neither `xml` nor `file` is given, the Draft copies the
#'   published definition.
#'   Default: `NULL`.
#' @param file (character) Path to a local `.xml`, `.xls` or `.xlsx` file
#'   holding the Form definition.
#'   Default: `NULL`.
#' @param ignore_warnings (lgl) If `TRUE`, the Draft is created even if
#'   the XLSForm conversion results in warnings.
#'   Only used for `.xls`/`.xlsx` uploads.
#'   Default: `FALSE`.
#' @param xls_form_id_fallback (character) The form ID to use if an
#'   uploaded spreadsheet does not specify one.
#'   Only used for `.xls`/`.xlsx` uploads.
#'   Default: `NULL` (no header sent).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#creating-a-draft-form}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' fl <- form_list()
#'
#' form_draft_create(fid = fl$fid[[1]])
#' # > $success
#' # > [1] TRUE
#' }
form_draft_create <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  xml = NULL,
  file = NULL,
  ignore_warnings = FALSE,
  xls_form_id_fallback = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  has_xml <- is.character(xml) &&
    length(xml) == 1L &&
    !is.na(xml) &&
    nzchar(xml)
  has_file <- is.character(file) && length(file) == 1L && !is.na(file)
  if (has_xml && has_file) {
    ru_msg_abort("Pass only one of 'xml' and 'file'.")
  }

  parts <- ru_form_upload(
    xml = if (has_xml) xml else NULL,
    file = if (has_file) file else NULL,
    xls_form_id_fallback = xls_form_id_fallback
  )

  query <- list()
  if (isTRUE(ignore_warnings)) {
    query$ignoreWarnings <- "true"
  }

  headers <- c(
    unlist(parts$extra_headers)
  )
  if (!is.null(parts$body)) {
    headers <- c(headers, "Content-Type" = parts$content_type)
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/draft"
    ),
    query = query,
    headers = headers,
    un = un,
    pw = pw,
    body = parts$body,
    encode = "raw",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("form_draft_create")  # nolint
