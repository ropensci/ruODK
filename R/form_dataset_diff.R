#' Show Datasets affected by one Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint lists the name and Properties of a Dataset that are
#' affected by a Form.
#' The list of Properties includes all published Properties of that
#' Dataset, but each Property has the `inForm` flag to note whether or
#' not that Form fills it in.
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with one entry per affected Dataset, each holding the
#'   Dataset `name` and its `properties` with `inForm` flags.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#published-form-related-datasets}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' fl <- form_list()
#'
#' dd <- form_dataset_diff(fid = fl$fid[[1]])
#'
#' dd |> listviewer::jsonedit()
#' }
form_dataset_diff <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/dataset-diff"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")
}

# usethis::use_test("form_dataset_diff")  # nolint
