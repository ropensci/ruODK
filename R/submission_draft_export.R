#' Export Draft Submissions to CSV.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This downloads the ZIP export of a Draft Form's Submissions: the
#' Submission data with related repeat table files and media files.
#'
#' @template param-pid
#' @template param-fid
#' @param dest (character) The local file path to save the ZIP export
#'   to.
#'   Default: `NULL`, which saves to a temporary `.zip` file.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return The local file path the ZIP export was saved to.
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
#'
#' zip <- submission_draft_export(fid = fl$fid[[1]])
#'
#' file.info(zip)$size
#' }
submission_draft_export <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  dest = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (is.null(dest)) {
    dest <- tempfile(fileext = ".zip")
  }
  if (!is.character(dest) || length(dest) != 1L || is.na(dest)) {
    ru_msg_abort("dest must be a single file path.")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/draft/submissions.csv.zip"
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

# usethis::use_test("submission_draft_export")  # nolint
