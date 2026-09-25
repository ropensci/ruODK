#' Download one Draft Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This returns the XML of one Submission made to a Draft Form as a
#' nested list.
#' Repeating subgroups stay nested, since their presence and length
#' depend on the Submission data.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A nested list of Draft Submission data.
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
#'
#' sub <- submission_draft_get(sl$instance_id[[1]], fid = fid)
#'
#' names(sub)
#' }
submission_draft_get <- function(
  iid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/draft/submissions/{iid}.xml"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_xml() |>
    xml2::as_list() |>
    magrittr::extract2("data")
}

# usethis::use_test("submission_draft_get")  # nolint
