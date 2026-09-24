#' Clear an attachment of a Draft Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' A DELETE to a Draft Submission attachment's endpoint clears the
#' uploaded bytes while the expected file slot remains listed.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @param filename (character) The name of the expected file slot, as
#'   given by `submission_draft_attachment_list()`.
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
#' submission_draft_attachment_delete(iid, fid = fid, filename = "photo.jpg")
#' # > $success
#' # > [1] TRUE
#' }
submission_draft_attachment_delete <- function(
  iid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  filename,
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

  httr::RETRY(
    "DELETE",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/draft/submissions/{iid}/",
        "attachments/{URLencode(filename, reserved = TRUE)}"
      )
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("submission_draft_attachment_delete")  # nolint
