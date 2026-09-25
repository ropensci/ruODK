#' Upload an attachment of a Draft Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' To upload a binary to an expected file slot of a Draft Submission,
#' POST the binary to its endpoint.
#' Supply a `content_type` if you have one.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @param filename (character) The name of the expected file slot, as
#'   given by `submission_draft_attachment_list()`.
#' @param file (character) Path to a local file whose bytes are uploaded
#'   to the expected file slot.
#' @param content_type (character) The MIME type sent as `Content-Type`
#'   header.
#'   Default: `NULL`, which sends `"application/octet-stream"`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
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
#' submission_draft_attachment_upload(
#'   iid,
#'   fid = fid,
#'   filename = "photo.jpg",
#'   file = "/path/to/photo.jpg"
#' )
#' }
# nolint start
submission_draft_attachment_upload <- function(
  # nolint end
  iid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  filename,
  file,
  content_type = NULL,
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
  if (
    missing(file) ||
      !is.character(file) ||
      length(file) != 1L ||
      is.na(file)
  ) {
    ru_msg_abort("file must be a single file path.")
  }
  if (!file.exists(file)) {
    ru_msg_abort(glue::glue("File not found: {file}"))
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/draft/submissions/{iid}/",
      "attachments/{URLencode(filename, reserved = TRUE)}"
    ),
    headers = c(
      "Content-Type" = content_type %||% "application/octet-stream"
    ),
    un = un,
    pw = pw,
    body = readBin(file, "raw", file.info(file)$size),
    encode = "raw",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("submission_draft_attachment_upload")  # nolint
