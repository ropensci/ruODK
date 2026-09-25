#' Download one attachment of a Submission version.
#'
#' `r lifecycle::badge("experimental")`
#'
#' If the server holds a copy of the expected file, append its filename
#' to the version attachments URL to download only that file.
#'
#' @template param-iid
#' @param vid (character) The `instanceID` of the particular version of
#'   this Submission, e.g. from `submission_versions()`.
#' @template param-pid
#' @template param-fid
#' @param filename (character) The name of the file to download, as
#'   given by `submission_version_attachment_list()`.
#' @param dest (character) The local file path to save the attachment
#'   to.
#'   Default: `NULL`, which saves to a temporary file with the same
#'   extension.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return The local file path the attachment was saved to.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#downloading-a-version-s-attachment}
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
#' sv <- submission_versions(iid)
#' vid <- sv$instance_id[[1]]
#'
#' al <- submission_version_attachment_list(iid, vid = vid)
#'
#' path <- submission_version_attachment_download(iid, vid = vid, filename = al$name[[1]]) # nolint
#'
#' file.info(path)$size
#' }
# nolint start
submission_version_attachment_download <- function(
  # nolint end
  iid,
  vid,
  filename,
  pid = get_default_pid(),
  fid = get_default_fid(),
  dest = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  if (
    missing(vid) ||
      !is.character(vid) ||
      length(vid) != 1L ||
      is.na(vid) ||
      !nzchar(vid)
  ) {
    ru_msg_abort("vid must be a single non-empty character string.")
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
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}/",
      "versions/{vid}/attachments/",
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

# usethis::use_test("submission_version_attachment_download")  # nolint
