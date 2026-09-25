#' Show the XML of one published Form version.
#'
#' `r lifecycle::badge("experimental")`
#'
#' To get the XML of a published Form version, this function requests
#' the version resource with `.xml` appended.
#' Since the XForms specification allows blank strings as versions, pass
#' the special value `___` (three underscores) as the version to
#' retrieve the blank version.
#'
#' @param parse Whether to parse the XML into a nested list, default: TRUE
#' @template param-pid
#' @template param-fid
#' @param version (character) The version of the Form version being
#'   referenced.
#'   Pass `___` for a blank version.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return The Form version XML as a nested list, or the raw response if
#'   `parse` is `FALSE`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#retrieving-form-version-xml}
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
#' vx <- form_version_xml(fid = fid, version = vl$version[[1]])
#'
#' names(vx)
#' }
form_version_xml <- function(
  parse = TRUE,
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

  out <- ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}/",
      "versions/{URLencode(version, reserved = TRUE)}.xml"
    ),
    accept = "application/xml",
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_xml()

  if (parse == FALSE) {
    return(out)
  }
  out |> xml2::as_list()
}

# usethis::use_test("form_version_xml")  # nolint
