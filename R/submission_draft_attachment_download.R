#' Download one attachment of a Draft Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' If the server holds a copy of the expected file, append its filename
#' to the Draft Submission attachments URL to download only that file.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @param filename (character) The name of the file to download, as
#'   given by `submission_draft_attachment_list()`.
#' @param dest (character) The local file path to save the attachment
#'   to.
#'   Default: `NULL`, which saves to a temporary file with the same
#'   extension.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return The local file path the attachment was saved to.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#draft-submissions}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' fl <- form_list()
#' fid <- fl$fid[[1]]
#'
#' sl <- submission_draft_list(fid = fid)
#' iid <- sl$instance_id[[1]]
#'
#' al <- submission_draft_attachment_list(iid, fid = fid)
#'
#' path <- submission_draft_attachment_download(iid, fid = fid, filename = al$name[[1]]) # nolint
#'
#' file.info(path)$size
#' }
# nolint start
submission_draft_attachment_download <- function(
  # nolint end
  iid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  filename,
  dest = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

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
        "{URLencode(fid, reserved = TRUE)}/draft/submissions/{iid}/",
        "attachments/{URLencode(filename, reserved = TRUE)}"
      )
    ),
    httr::write_disk(dest, overwrite = TRUE),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw)

  dest
}

# usethis::use_test("submission_draft_attachment_download")  # nolint
