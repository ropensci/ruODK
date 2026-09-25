#' Upload a Draft Form attachment.
#'
#' `r lifecycle::badge("experimental")`
#'
#' To upload a binary to an expected file slot, POST the binary to its
#' endpoint.
#' Supply a `content_type` if you have one.
#' If a Dataset is linked to this attachment, the upload unlinks and
#' replaces it with the uploaded file.
#'
#' @template param-pid
#' @template param-fid
#' @param filename (character) The name of the expected file slot, as
#'   given by `form_draft_attachment_list()`.
#' @param file (character) Path to a local file whose bytes are uploaded
#'   to the expected file slot.
#' @param content_type (character) The MIME type sent as `Content-Type`
#'   header.
#'   Default: `NULL`, which sends `"application/octet-stream"`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the updated attachment's metadata as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#uploading-a-draft-form-attachment}
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
#' al <- form_draft_attachment_list(fid = fid)
#'
#' form_draft_attachment_upload(
#'   fid = fid,
#'   filename = al$name[[1]],
#'   file = "/path/to/file.csv"
#' )
#' }
form_draft_attachment_upload <- function(
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
      "{URLencode(fid, reserved = TRUE)}/draft/attachments/",
      "{URLencode(filename, reserved = TRUE)}"
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
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("form_draft_attachment_upload")  # nolint
