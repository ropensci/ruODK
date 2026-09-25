#' Show the XML of one Submission version.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Returns the XML of a particular version of the Submission.
#'
#' @template param-iid
#' @param vid (character) The `instanceID` of the particular version of
#'   this Submission, e.g. from `submission_versions()`.
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A nested list of the Submission version's XML data.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#getting-version-xml}
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
#' sv <- submission_versions(iid)
#'
#' vx <- submission_version_xml(iid, vid = sv$instance_id[[1]])
#'
#' listviewer::jsonedit(vx)
#' }
submission_version_xml <- function(
  iid,
  vid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  if (
    missing(vid) ||
      !is.character(vid) ||
      length(vid) != 1L ||
      is.na(vid) ||
      !nzchar(vid)
  ) {
    ru_msg_abort("vid must be a single non-empty character string.")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}/",
      "versions/{vid}.xml"
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

# usethis::use_test("submission_version_xml")  # nolint
