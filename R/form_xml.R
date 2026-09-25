#' Show the XML representation of one form as list.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param parse Whether to parse the XML into a nested list, default: TRUE
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return The form XML as a nested list.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#retrieving-form-xml}
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
#' }
form_xml <- function(
  parse = TRUE,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  out <- ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}.xml"
    ),
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
