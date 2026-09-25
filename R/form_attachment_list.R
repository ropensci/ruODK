#' List all attachments of one Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint fetches the list of expected attachment files, and
#' tells whether the server holds each file or not, and a hash of the
#' file contents.
#' To modify an attachment, create a Draft.
#' The property `datasetExists` tells whether the attachment is a link
#' to a Dataset instead of an actual file.
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row per expected Form attachment and the
#'   columns `name`, `type`, `exists`, `blob_exists`, `dataset_exists`,
#'   `size`, `hash` and `updated_at`, as far as Central returns them.
#'   Column names are renamed from ODK Central's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#listing-form-attachments}
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
#' al <- form_attachment_list(fid = fl$fid[[1]])
#'
#' al |> knitr::kable()
#' }
form_attachment_list <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  resp <- ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/attachments"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json()

  tibble::tibble(attachments = resp) |>
    tidyr::unnest_wider("attachments", names_repair = "universal") |>
    janitor::clean_names()
}

# usethis::use_test("form_attachment_list")  # nolint
