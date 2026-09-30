#' Show the XML representation of one form as list.
#'
#' `r lifecycle::badge("stable")`
#'
#' To get the XML of the Form, add `.xml` to the end of the request URL.
#' To get the XML of one published Form version, request the version
#' resource with `.xml` appended.
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
#'   If `NULL` (default), the published Form XML is returned.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return The form XML as a nested list.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#retrieving-form-xml}
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#retrieving-form-version-xml}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' # With explicit pid and fid
#' fxml_defaults <- form_xml(1, "build_xformsId")
#'
#' # With defaults
#' fxml <- form_xml()
#' listviewer::jsonedit(fxml)
#'
#' # form_xml returns a nested list
#' class(fxml)
#' # > "list"
#'
#' # The XML of one published Form version
#' vl <- form_version_list()
#' fxml_v1 <- form_xml(version = vl$version[[1]], parse = FALSE)
#' }
form_xml <- function(
  parse = TRUE,
  pid = get_default_pid(),
  fid = get_default_fid(),
  version = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  if (!is.null(version)) {
    if (
      !is.character(version) ||
        length(version) != 1L ||
        is.na(version) ||
        !nzchar(version)
    ) {
      ru_msg_abort("version must be a single non-empty character string.")
    }
    pth <- glue::glue(
      "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}/",
      "versions/{URLencode(version, reserved = TRUE)}.xml"
    )
  } else {
    pth <- glue::glue(
      "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}.xml"
    )
  }
  out <- ru_http_request(
    "GET",
    url,
    path = pth,
    accept = "application/xml",
    un = un,
    pw = pw,
    retries = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr2::resp_body_xml()

  if (parse == FALSE) {
    return(out)
  }
  out %>% xml2::as_list(.)
}

# usethis::use_test("form_xml") # nolint
