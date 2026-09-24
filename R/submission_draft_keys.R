#' List encryption keys of Draft Submissions.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This lists the managed and self-supplied encryption keys of
#' Submissions made to a Draft Form.
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-orders
#' @template param-tz
#' @return A tibble with one row per encryption key and all key
#'   metadata as columns as per the ODK Central API docs.
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
#' kl <- submission_draft_keys(fid = fl$fid[[1]])
#'
#' kl |> knitr::kable()
#' }
submission_draft_keys <- function(
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

  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/draft/submissions/keys"
      )
    ),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    (\(resp) tibble::tibble(keys = resp))() |>
    tidyr::unnest_wider("keys", names_repair = "universal") |>
    janitor::clean_names() |>
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("submission_draft_keys")  # nolint
