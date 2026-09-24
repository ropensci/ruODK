#' Create a Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' To create a Submission by REST rather than over the OpenRosa interface,
#' POST the Submission XML to this endpoint.
#' Unlike the OpenRosa Form Submission API, this interface does not accept
#' Submission attachments upon Submission creation.
#' Instead, the server determines which attachments are expected based on
#' the Submission XML, and you can use `attachment_upload()` to add the
#' attachments afterwards.
#'
#' If the XML is unparseable or there is some other input problem with
#' your data, Central answers 400.
#' If a Submission already exists with the given `instanceID`,
#' Central answers 409.
#' The `<meta>` block holds a unique `instanceID` for each Submission.
#'
#' @template param-pid
#' @template param-fid
#' @param xml (character) The Submission XML as a single string.
#' @param device_id (character) Optionally record a particular `deviceID`
#'   associated with this Submission.
#'   It is recorded along with the data, but Central does nothing more
#'   with it.
#'   Default: `NULL` (not sent).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the new Submission's metadata as per the ODK Central
#'   API docs, identical in shape to `submission_detail()`.
#'   Top level list elements are renamed from ODK's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#creating-a-submission}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' xml <- paste0(
#'   '<data id="simple" version="1">',
#'   "<meta><instanceID>uuid:85cb9aff-005e-4edd-9739-dc9c1a829c44</instanceID></meta>", # nolint
#'   "<name>Jo</name>",
#'   "</data>"
#' )
#'
#' s <- submission_create(fid = "simple", xml = xml)
#'
#' s$instance_id
#' # > "uuid:85cb9aff-005e-4edd-9739-dc9c1a829c44"
#' }
submission_create <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  xml = NULL,
  device_id = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (!is.character(xml) || length(xml) != 1L || is.na(xml) || !nzchar(xml)) {
    ru_msg_abort("xml must be a single non-empty character string.")
  }

  query <- list()
  if (!is.null(device_id)) {
    query$deviceID <- device_id
  }

  httr::RETRY(
    "POST",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/submissions"
      ),
      query = query
    ),
    httr::add_headers(
      "Accept" = "application/json",
      "Content-Type" = "application/xml"
    ),
    body = xml,
    encode = "raw",
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("submission_create")  # nolint
