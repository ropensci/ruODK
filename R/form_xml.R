#' Show the XML representation of one form as list.
#'
#'
#'
#' @template param-pid
#' @template param-fid
#' @param parse Whether to parse the XML into a nested list, default: TRUE
#' @template param-auth
#' @return The form XML as a nested list.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/'-individual-form/retrieving-form-xml}
#' @family restful-api
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @importFrom xml2 as_list
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' fxml_defaults <- form_xml(1, "build_xformsId")
#'
#' # With explicit credentials, see tests
#' fxml <- form_xml(
#'   get_test_pid(),
#'   get_test_fid(),
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#' listviewer::jsonedit(fxml)
#'
#' # form_xml returns a nested list.
#' class(fxml)
#' # > "list"
#' }
form_xml <- function(pid,
                     fid,
                     parse = TRUE,
                     url = get_default_url(),
                     un = get_default_un(),
                     pw = get_default_pw()) {
  . <- NULL
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
