#' Review a Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Currently, the only updatable metadata on a Submission is its
#' `reviewState`.
#' To update the Submission data itself, see `submission_update()`.
#'
#' Starting with Version 2022.3, changing the `reviewState` of a
#' Submission to `approved` can create an Entity in a Dataset if the
#' corresponding Form maps Dataset Properties to Form Fields.
#'
#' This function records a review decision on a Submission.
#' Clearing the review state back to unreviewed (`received`) is not
#' supported by this function.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @param review_state (character) The new review state of the Submission.
#'   One of `"approved"`, `"hasIssues"` or `"rejected"`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the reviewed Submission's metadata as per the ODK
#'   Central API docs.
#'   Top level list elements are renamed from ODK's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#updating-submission-metadata}
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
#' s <- submission_review(sl$instance_id[[1]], review_state = "approved")
#'
#' s$review_state
#' # > "approved"
#' }
submission_review <- function(
  iid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  review_state = "",
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  if (
    !is.character(review_state) ||
      length(review_state) != 1L ||
      is.na(review_state) ||
      !(review_state %in% c("approved", "hasIssues", "rejected"))
  ) {
    ru_msg_abort(
      "review_state must be one of 'approved', 'hasIssues' or 'rejected'."
    )
  }

  ru_http_request(
    "PATCH",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}"
    ),
    un = un,
    pw = pw,
    body = list(reviewState = review_state),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("submission_review")  # nolint
