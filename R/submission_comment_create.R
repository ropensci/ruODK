#' Post a comment to one Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' The only accepted data is `body`, which contains the body of the
#' comment to be made.
#' It is not possible to edit or delete a comment once it has been made.
#' This endpoint requires ODK Central v1.2 or later.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @param body (character) The text of the comment.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the new comment's `body` and the commenting
#'   Actor's `actor_id`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#posting-comments}
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
#' c <- submission_comment_create(sl$instance_id[[1]], "Looks good.")
#'
#' c$body
#' # > "Looks good."
#' }
submission_comment_create <- function(
  iid,
  body,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  if (
    !is.character(body) ||
      length(body) != 1L ||
      is.na(body) ||
      !nzchar(body)
  ) {
    ru_msg_abort("body must be a single non-empty character string.")
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}/comments"
    ),
    un = un,
    pw = pw,
    body = list(body = body),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("submission_comment_create")  # nolint
