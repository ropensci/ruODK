#' List expected attachments of one published Form version.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This lists the expected attachments of a published Form version with
#' a boolean flag telling whether the server holds a copy of each file
#' or not.
#'
#' @template param-pid
#' @template param-fid
#' @param version (character) The version of the Form version being
#'   referenced.
#'   Pass `___` for a blank version.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row per expected attachment and the columns
#'   `name` and `exists`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#listing-form-version-attachments}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' fl <- form_list()
#' fid <- fl$fid[[1]]
#'
#' vl <- form_version_list(fid = fid)
#'
#' al <- form_version_attachment_list(fid = fid, version = vl$version[[1]])
#'
#' al |> knitr::kable()
#' }
form_version_attachment_list <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  version,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (
    missing(version) ||
      !is.character(version) ||
      length(version) != 1L ||
      is.na(version) ||
      !nzchar(version)
  ) {
    ru_msg_abort("version must be a single non-empty character string.")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/versions/",
      "{URLencode(version, reserved = TRUE)}/attachments"
    ),
    un = un,
    pw = pw,
    retries = retries
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

# usethis::use_test("form_version_attachment_list")  # nolint
