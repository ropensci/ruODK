#' Create a Submission on a Draft Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' To create a Submission on a Draft Form by REST, POST the Submission
#' XML to this endpoint.
#' Draft Submissions test a Draft Form definition before publication.
#' If a Submission already exists with the given `instanceID`, Central
#' answers 409.
#'
#' @template param-pid
#' @template param-fid
#' @param xml (character) The Submission XML as a single string.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the new Draft Submission's metadata as per the
#'   ODK Central API docs.
#'   Top level list elements are renamed from ODK's `camelCase` to
#'   `snake_case`.
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
#' s <- submission_draft_create(
#'   fid = fl$fid[[1]],
#'   xml = "<data id=\"simple\"><meta><instanceID>uuid:1</instanceID></meta></data>" # nolint
#' )
#'
#' s$instance_id
#' }
submission_draft_create <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  xml = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (!is.character(xml) || length(xml) != 1L || is.na(xml) || !nzchar(xml)) {
    ru_msg_abort("xml must be a single non-empty character string.")
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/draft/submissions"
    ),
    headers = c("Content-Type" = "application/xml"),
    un = un,
    pw = pw,
    body = xml,
    encode = "raw",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("submission_draft_create")  # nolint
