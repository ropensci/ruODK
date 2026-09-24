#' List expected attachments of one Draft Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' When a Draft Submission is created, its XML data determines which
#' file attachments it references.
#' This lists the expected attachments with a boolean flag telling
#' whether the server holds a copy of each file or not.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row per expected attachment and the columns
#'   `name` and `exists`.
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
#' al <- submission_draft_attachment_list(sl$instance_id[[1]], fid = fid)
#'
#' al |> knitr::kable()
#' }
submission_draft_attachment_list <- function(
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
        "{URLencode(fid, reserved = TRUE)}/draft/submissions/{iid}/",
        "attachments"
      )
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    (\(resp) {
      tibble::tibble(
        name = purrr::map_chr(resp, "name"),
        exists = purrr::map_lgl(resp, "exists")
      )
    })()
}

# usethis::use_test("submission_draft_attachment_list")  # nolint
