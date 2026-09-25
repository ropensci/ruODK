#' Perform one HTTP request against ODK Central.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This is the centralised request helper for ruODK.
#' It builds an `httr2` request from plain data (verb, path, query,
#' headers, credentials, body) and returns the `httr2` response unchanged,
#' so `yell_if_error()` and the `httr2::resp_body_*()` parsers keep working
#' downstream.
#' The full URL keeps the legacy query semantics on purpose: query
#' values that callers pre-encode (for example `entitylist_download()`'s
#' `$filter`) must not be encoded twice.
#'
#' @param verb (character) The HTTP verb, e.g. `"GET"`, `"POST"`.
#' @param url (character) The base URL of the ODK Central server, or the
#'   complete request URL if `path` is `NULL`.
#' @param path (character) The request path, e.g. `"v1/projects"`.
#'   If `NULL`, `url` is used as the complete request URL.
#'   Default: `NULL`.
#' @param query (list) Optional query string parameters.
#'   Default: `NULL` (no query string).
#' @param accept (character) The `Accept` header value.
#'   Default: `"application/json"`.
#'   Set to `NULL` to send no `Accept` header.
#' @param headers (character) Optional extra headers as a named character
#'   vector, e.g. `c("X-Extended-Metadata" = "true")`.
#'   Default: `NULL` (no extra headers).
#' @param un (character) The ODK Central username for basic authentication.
#'   Default: `NULL` (no authentication).
#' @param pw (character) The ODK Central password for basic authentication.
#'   Default: `NULL` (no authentication).
#' @param body The request body.
#'   Default: `NULL` (no body).
#' @param encode (character) The body encoding: `"json"` sends JSON,
#'   anything else sends raw bytes.
#'   Default: `NULL` (no body).
#' @param dest (character) A local file path to stream a download to.
#'   Default: `NULL` (no streaming, the response is kept in memory).
#' @param overwrite (lgl) Whether to overwrite `dest` if it exists.
#'   Only used with `dest`.
#'   Default: `TRUE`.
#' @param terminate_on (numeric) HTTP status codes that stop retries
#'   immediately.
#'   Default: `NULL` (only non-transient statuses stop retries).
#' @template param-retries
#' @return The `httr` response object, unmodified.
#' @family utilities
#' @keywords internal
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' resp <- ruODK:::ru_http_request(
#'   "GET",
#'   url = get_test_url(),
#'   path = "v1/projects",
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' httr2::resp_status(resp)
#' }
ru_http_request <- function(
  verb,
  url,
  path = NULL,
  query = NULL,
  accept = "application/json",
  headers = NULL,
  un = NULL,
  pw = NULL,
  body = NULL,
  encode = NULL,
  dest = NULL,
  overwrite = TRUE,
  terminate_on = NULL,
  retries = get_retries()
) {
  # URL building preserves exact legacy semantics: the path is appended
  # verbatim (httr2::url_modify() would encode `$` in paths like `$metadata`
  # and `?` in embedded query strings, which httr left alone), while added
  # query values are encoded exactly like httr::modify_url() did (verified
  # empirically, including pre-encoded values). NULL query values are
  # dropped silently, like httr did.
  if (is.null(path) && !is.null(query)) {
    ru_msg_abort("ru_http_request needs a path to add a query string.")
  }
  full_url <- if (is.null(path)) {
    url
  } else {
    paste0(sub("/+$", "", url), "/", path)
  }
  if (!is.null(query)) {
    query <- Filter(Negate(is.null), query)
    full_url <- httr2::url_modify(full_url, query = query)
  }

  req <- httr2::request(full_url) |> httr2::req_method(verb)

  all_headers <- c(Accept = accept, headers)
  if (length(all_headers) > 0) {
    req <- httr2::req_headers(req, !!!all_headers)
  }
  if (!is.null(un) && !is.null(pw)) {
    req <- httr2::req_auth_basic(req, un, pw)
  }
  if (!is.null(body)) {
    if (identical(encode, "json")) {
      req <- httr2::req_body_json(req, body)
    } else {
      req <- httr2::req_body_raw(req, body)
    }
  } else if (verb %in% c("POST", "PUT", "PATCH")) {
    # httr sends Content-Length: 0 on bodiless writes; Central rejects
    # the request without it.
    req <- httr2::req_body_raw(req, raw(0))
  }

  transient_codes <- c(429L, setdiff(500:599, terminate_on %||% integer(0)))
  req <- httr2::req_retry(
    req,
    max_tries = max(retries, 1L),
    is_transient = function(resp) httr2::resp_status(resp) %in% transient_codes
  )

  if (!is.null(dest)) {
    if (!overwrite && file.exists(dest)) {
      ru_msg_abort(glue::glue('File "{dest}" already exists.'))
    }
    httr2::req_perform(req, path = dest)
  } else {
    httr2::req_perform(req)
  }
}

# usethis::use_test("ru_http")  # nolint
