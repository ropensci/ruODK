#' List all comments of one Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Comments have only a body comment text and an Actor that made the
#' comment.
#' It is not possible to get a specific comment's details, or to edit or
#' delete a comment once it has been made.
#' This endpoint requires ODK Central v1.2 or later.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row per comment and the columns `body` (the
#'   comment text) and `actor_id` (the ID of the commenting Actor).
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#listing-comments}
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
#' cl <- submission_comment_list(sl$instance_id[[1]])
#'
#' cl |> knitr::kable()
#' }
submission_comment_list <- function(
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
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}/comments"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    (\(resp) {
      tibble::tibble(
        body = purrr::map_chr(resp, "body"),
        actor_id = purrr::map_int(resp, "actorId")
      )
    })()
}

# usethis::use_test("submission_comment_list")  # nolint
