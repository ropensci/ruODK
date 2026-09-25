#' Download the XLSForm of one Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' If a Form was created with an Excel file (`.xls` or `.xlsx`), this
#' function gets that file back.
#' Forms created from XForms XML have no spreadsheet source, and Central
#' answers those requests with 404.
#'
#' @template param-pid
#' @template param-fid
#' @param dest (character) The local file path to save the spreadsheet
#'   to.
#'   Default: `NULL`, which saves to a temporary `.xlsx` file.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return The local file path the spreadsheet was saved to.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#retrieving-form-xls-x}
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
#' xlsx <- form_xlsx(fid = fl$fid[[1]])
#'
#' file.info(xlsx)$size
#' }
form_xlsx <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  dest = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (is.null(dest)) {
    dest <- tempfile(fileext = ".xlsx")
  }
  if (!is.character(dest) || length(dest) != 1L || is.na(dest)) {
    ru_msg_abort("dest must be a single file path.")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}.xlsx"
    ),
    accept = paste0(
      "application/vnd.openxmlformats-officedocument.",
      "spreadsheetml.sheet"
    ),
    un = un,
    pw = pw,
    dest = dest,
    overwrite = TRUE,
    retries = retries
  ) |>
    yell_if_error(url, un, pw)

  dest
}

# usethis::use_test("form_xlsx")  # nolint
