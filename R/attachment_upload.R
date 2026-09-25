#' Upload a Submission attachment.
#'
#' `r lifecycle::badge("experimental")`
#'
#' To upload a binary to an expected file slot, POST the binary to its
#' endpoint.
#' The expected file slots are determined by the Submission XML;
#' list them with `attachment_list()`.
#' `filename` must match a slot name from the attachment listing.
#' `file` is the local file.
#' Its bytes fill the slot.
#'
#' @template param-iid
#' @param filename (character) The name of the file as given by the
#'   attachment listing resource, e.g. `"file1.jpg"`.
#' @param file (character) Path to a local file whose bytes are uploaded
#'   to the expected file slot.
#' @param content_type (character) The MIME type sent as `Content-Type`
#'   header, e.g. `"image/jpeg"`.
#'   Default: `NULL`, which sends `"application/octet-stream"`.
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#uploading-an-attachment}
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
#' al <- attachment_list(iid)
#' al$name
#' # > "photo.jpg"
#'
#' attachment_upload(iid, "photo.jpg", "/path/to/photo.jpg")
#' # > $success
#' # > [1] TRUE
#' }
attachment_upload <- function(
  iid,
  filename,
  file,
  content_type = NULL,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  if (
    !is.character(filename) ||
      length(filename) != 1L ||
      is.na(filename) ||
      !nzchar(filename)
  ) {
    ru_msg_abort("filename must be a single non-empty character string.")
  }
  if (!is.character(file) || length(file) != 1L || is.na(file)) {
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
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}/",
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

# usethis::use_test("attachment_upload")  # nolint
