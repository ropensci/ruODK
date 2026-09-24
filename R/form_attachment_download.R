#' Download one Form attachment.
#'
#' `r lifecycle::badge("experimental")`
#'
#' To download a single file, use this endpoint.
#' The `Content-Type` is either the type supplied at upload time, a type
#' derived from the file extension, or `application/octet-stream`.
#'
#' @template param-pid
#' @template param-fid
#' @param filename (character) The name of the file to download, as
#'   given by `form_attachment_list()`.
#' @param dest (character) The local file path to save the attachment
#'   to.
#'   Default: `NULL`, which saves to a temporary file with the same
#'   extension.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return The local file path the attachment was saved to.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#downloading-a-form-attachment}
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
#' al <- form_attachment_list(fid = fid)
#'
#' path <- form_attachment_download(fid = fid, filename = al$name[[1]])
#'
#' file.info(path)$size
#' }
form_attachment_download <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  filename,
  dest = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

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

  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/attachments/",
        "{URLencode(filename, reserved = TRUE)}"
      )
    ),
    httr::write_disk(dest, overwrite = TRUE),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw)

  dest
}

# usethis::use_test("form_attachment_download")  # nolint
