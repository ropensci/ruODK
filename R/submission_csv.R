#' Export the root Submission table to CSV.
#'
#' `r lifecycle::badge("experimental")`
#'
#' The ZIP export endpoints provide all possible related repeat table
#' files, as well as the media files associated with the Submissions.
#' To export just the root table (no repeat data nor media files), call
#' this endpoint instead, which directly gives CSV data.
#' An OData-style `$filter` query filters the Submissions.
#' This endpoint requires ODK Central v1.1 or later.
#'
#' @template param-pid
#' @template param-fid
#' @param filter (character) An OData-style `$filter` query to filter
#'   the Submissions by.
#'   Only certain fields are available to reference.
#'   Default: `NULL` (not sent).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with the root Submission table, one row per
#'   Submission.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#exporting-root-data-to-plain-csv}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' csv <- submission_csv()
#'
#' csv |> knitr::kable()
#' }
submission_csv <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  filter = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  query <- list()
  if (!is.null(filter)) {
    query[["$filter"]] <- filter
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions.csv"
    ),
    query = query,
    accept = "text/csv",
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(as = "text", encoding = "utf-8") |>
    I() |>
    readr::read_csv(show_col_types = FALSE) |>
    tibble::as_tibble()
}

# usethis::use_test("submission_csv")  # nolint
