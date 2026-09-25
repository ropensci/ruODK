#' Show details of one Submission version.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Returns metadata about a particular version of the Submission.
#' As with the normal Submission endpoint, this route returns only
#' metadata in JSON.
#'
#' @template param-iid
#' @param vid (character) The `instanceID` of the particular version of
#'   this Submission, e.g. from `submission_versions()`.
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the Submission version's
#'   metadata as columns as per the ODK Central API docs.
#'   Column names are renamed from ODK Central's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#getting-version-details}
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
#' vd <- submission_version_detail(iid, vid = sv$instance_id[[1]])
#'
#' vd |> knitr::kable()
#' }
submission_version_detail <- function(
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
      "versions/{vid}"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    (\(resp) {
      tibble::tibble(
        instance_id = resp$instanceId,
        instance_name = resp$instanceName %||% NA_character_,
        submitter_id = resp$submitterId,
        device_id = resp$deviceId %||% NA_character_,
        user_agent = resp$userAgent %||% NA_character_,
        created_at = resp$createdAt,
        current = resp$current,
        form_version = resp$formVersion %||% NA_character_
      )
    })()
}

# usethis::use_test("submission_version_detail")  # nolint
