#' Show the XML representation of one form as list.
#'
#' \lifecycle{stable}
#'
#' @param parse Whether to parse the XML into a nested list, default: TRUE
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @return The form XML as a nested list.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/'-individual-form/retrieving-form-xml}
# nolint end
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = paste0(
#'     "https://sandbox.central.opendatakit.org/v1/projects/14/",
#'     "forms/build_Flora-Quadrat-0-2_1558575936.svc"
#'   ),
#'   un = "me@email.com",
#'   pw = "..."
#' )
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
form_xml <- function(parse = TRUE,
                     pid = get_default_pid(),
                     fid = get_default_fid(),
                     url = get_default_url(),
                     un = get_default_un(),
                     pw = get_default_pw()) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  out <- glue::glue("{url}/v1/projects/{pid}/forms/{fid}.xml") %>%
    httr::GET(
      httr::add_headers("Accept" = "application/xml"),
      httr::authenticate(un, pw)
    ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.)

  if (parse == FALSE) {
    return(out)
  }
  out %>% xml2::as_list(.)
}

# Tests
# usethis::edit_file("tests/testthat/test-form_xml.R")
