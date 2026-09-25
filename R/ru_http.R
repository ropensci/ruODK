#' Perform one HTTP request against ODK Central.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This is the centralised request helper for ruODK.
#' It builds an `httr::RETRY()` call from plain data (verb, path, query,
#' headers, credentials, body) and returns the `httr` response unchanged,
#' so `yell_if_error()` and `httr::content()` keep working downstream.
#' Future work (issue #154) replaces the `httr` engine inside this single
#' function with `httr2`, without touching the callers.
#'
#' @param verb (character) The HTTP verb, e.g. `"GET"`, `"POST"`.
#' @param url (character) The base URL of the ODK Central server.
#' @param path (character) The request path, e.g. `"v1/projects"`.
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
#' @param body The request body, passed on to `httr::RETRY()`.
#'   Default: `NULL` (no body).
#' @param encode (character) The body encoding, passed on to `httr::RETRY()`.
#'   Default: `NULL` (httr default).
#' @param dest (character) A local file path to stream a download to.
#'   Default: `NULL` (no streaming, the response is kept in memory).
#' @param overwrite (lgl) Whether to overwrite `dest` if it exists.
#'   Only used with `dest`.
#'   Default: `TRUE`.
#' @param terminate_on (numeric) HTTP status codes that stop retries
#'   immediately, passed on to `httr::RETRY()`.
#'   Default: `NULL` (httr default).
#' @param quiet (lgl) Whether to suppress `httr::RETRY()` progress output.
#'   Default: `FALSE`.
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
#' httr::status_code(resp)
#' }
ru_http_request <- function(
  verb,
  url,
  path,
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
  quiet = FALSE,
  retries = get_retries()
) {
  httr::RETRY(
    verb,
    httr::modify_url(url, path = path, query = query),
    if (length(c(Accept = accept, headers)) > 0) {
      httr::add_headers(.headers = c(Accept = accept, headers))
    },
    if (!is.null(un) && !is.null(pw)) httr::authenticate(un, pw),
    body = body,
    encode = encode,
    if (!is.null(dest)) httr::write_disk(dest, overwrite = overwrite),
    terminate_on = terminate_on,
    quiet = quiet,
    times = retries
  )
}

# usethis::use_test("ru_http")  # nolint
