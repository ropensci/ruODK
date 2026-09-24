#' Download the XLSForm of one published Form version.
#'
#' `r lifecycle::badge("experimental")`
#'
#' If a Form Version was created with an Excel file (`.xls` or
#' `.xlsx`), this function gets that file back.
#' Versions created from XForms XML have no spreadsheet source, and
#' Central answers those requests with 404.
#'
#' @template param-pid
#' @template param-fid
#' @param version (character) The version of the Form version being
#'   referenced.
#'   Pass `___` for a blank version.
#' @param dest (character) The local file path to save the spreadsheet
#'   to.
#'   Default: `NULL`, which saves to a temporary `.xlsx` file.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return The local file path the spreadsheet was saved to.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#retrieving-form-version-xls-x}
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
#' xlsx <- form_version_xlsx(fid = fid, version = vl$version[[1]])
#'
#' file.info(xlsx)$size
#' }
form_version_xlsx <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  version,
  dest = NULL,
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
  if (is.null(dest)) {
    dest <- tempfile(fileext = ".xlsx")
  }
  if (!is.character(dest) || length(dest) != 1L || is.na(dest)) {
    ru_msg_abort("dest must be a single file path.")
  }

  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}/",
        "versions/{URLencode(version, reserved = TRUE)}.xlsx"
      )
    ),
    httr::add_headers(
      "Accept" = paste0(
        "application/vnd.openxmlformats-officedocument.",
        "spreadsheetml.sheet"
      )
    ),
    httr::write_disk(dest, overwrite = TRUE),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw)

  dest
}

# usethis::use_test("form_version_xlsx")  # nolint
