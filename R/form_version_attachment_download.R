#' Download one attachment of a published Form version.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Attachments are specific to each version of a Form.
#' If the server holds a copy of the expected file, append its filename
#' to the version attachments URL to download only that file.
#'
#' @template param-pid
#' @template param-fid
#' @param version (character) The version of the Form version being
#'   referenced.
#'   Pass `___` for a blank version.
#' @param filename (character) The name of the file to download, as
#'   given by `form_version_attachment_list()`.
#' @param dest (character) The local file path to save the attachment
#'   to.
#'   Default: `NULL`, which saves to a temporary file with the same
#'   extension.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return The local file path the attachment was saved to.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#downloading-a-form-version-attachment}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' fl <- form_list()
#' fid <- fl$fid[[1]]
#'
#' vl <- form_version_list(fid = fid)
#' version <- vl$version[[1]]
#'
#' al <- form_version_attachment_list(fid = fid, version = version)
#'
#' path <- form_version_attachment_download(
#'   fid = fid,
#'   version = version,
#'   filename = al$name[[1]]
#' )
#'
#' file.info(path)$size
#' }
# nolint start
form_version_attachment_download <- function(
  # nolint end
  pid = get_default_pid(),
  fid = get_default_fid(),
  version,
  filename,
  dest = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (
    missing(version) ||
      !is.character(version) ||
      length(version) != 1L ||
      is.na(version) ||
      !nzchar(version)
  ) {
    ru_msg_abort("version must be a single non-empty character string.")
  }
  if (
    missing(filename) ||
      !is.character(filename) ||
      length(filename) != 1L ||
      is.na(filename) ||
      !nzchar(filename)
  ) {
    ru_msg_abort("filename must be a single non-empty character string.")
  }
  if (is.null(dest)) {
    dest <- tempfile(fileext = paste0(".", tools::file_ext(filename)))
  }
  if (!is.character(dest) || length(dest) != 1L || is.na(dest)) {
    ru_msg_abort("dest must be a single file path.")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/versions/",
      "{URLencode(version, reserved = TRUE)}/attachments/",
      "{URLencode(filename, reserved = TRUE)}"
    ),
    accept = NULL,
    un = un,
    pw = pw,
    dest = dest,
    overwrite = TRUE,
    retries = retries
  ) |>
    yell_if_error(url, un, pw)

  dest
}

# usethis::use_test("form_version_attachment_download")  # nolint
