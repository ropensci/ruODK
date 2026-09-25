#' Clear a Submission attachment.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Because Submission Attachments are completely determined by the XML
#' data of the Submission itself, there is no direct way to entirely
#' remove a Submission Attachment entry from the list, only to clear its
#' uploaded content.
#' Thus, a DELETE to the attachment's endpoint clears the uploaded bytes
#' while the expected file slot remains listed.
#' This endpoint clears attachments on the current version of the
#' Submission.
#'
#' @template param-iid
#' @param filename (character) The name of the file as given by the
#'   attachment listing resource, e.g. `"file1.jpg"`.
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#clearing-a-submission-attachment}
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
#' attachment_delete(iid, "photo.jpg")
#' # > $success
#' # > [1] TRUE
#' }
attachment_delete <- function(
  iid,
  filename,
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

  ru_http_request(
    "DELETE",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}/",
      "attachments/{URLencode(filename, reserved = TRUE)}"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("attachment_delete")  # nolint
