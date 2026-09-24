#' Show changes between versions of one Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This returns the changes, or edits, between different versions of a
#' Submission.
#' These changes are returned in an object that is indexed by the
#' `instanceID` that uniquely identifies each version.
#' Between two Submissions, there is an array of objects representing how
#' each field changed.
#' Each change object contains the old and new values, as well as the
#' path of that changed node in the Submission XML.
#' These changes reflect the updated `instanceID` and `deprecatedID`
#' fields as well as the edited value.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list indexed by version `instanceID`.
#'   Each entry holds the field changes with `old` and `new` values and
#'   the `path` of the changed node.
#'   Names are kept exactly as returned by Central so versions stay
#'   addressable by `instanceID`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#getting-changes-between-versions}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' sl <- submission_list()
#'
#' d <- submission_changes(sl$instance_id[[1]])
#'
#' d |> listviewer::jsonedit()
#' }
submission_changes <- function(
  iid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/submissions/{iid}/diffs"
      )
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")
}

# usethis::use_test("submission_changes")  # nolint
