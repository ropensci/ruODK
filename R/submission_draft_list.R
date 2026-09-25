#' List all Submissions of a Draft Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This lists every Submission made to the Draft Form, every time.
#' Draft Submissions test a Draft Form definition before publication.
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-orders
#' @template param-tz
#' @return A tibble with one row per Draft Submission and all Submission
#'   metadata as columns as per the ODK Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#listing-all-submissions-on-a-draft-form}
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
#' sl <- submission_draft_list(fid = fl$fid[[1]])
#'
#' sl |> knitr::kable()
#' }
submission_draft_list <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  tbl <- ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/draft/submissions"
    ),
    headers = c("X-Extended-Metadata" = "true"),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    (\(resp) tibble::tibble(submissions = resp))() |>
    tidyr::unnest_wider("submissions", names_repair = "universal")

  if (nrow(tbl) == 0L) {
    return(janitor::clean_names(tbl))
  }

  tbl |>
    tidyr::unnest_wider(
      "submitter",
      names_repair = "universal",
      names_sep = "_"
    ) |>
    janitor::clean_names() |>
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("submission_draft_list")  # nolint
