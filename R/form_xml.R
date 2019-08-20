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
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
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
                     url = Sys.getenv("ODKC_URL"),
                     un = Sys.getenv("ODKC_UN"),
                     pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  out <- glue::glue(
    "{url}/v1/projects/{pid}/forms/{fid}.xml"
  ) %>%
    httr::GET(
      httr::add_headers("Accept" = "application/xml"),
      httr::authenticate(un, pw)
    ) %>%
    httr::stop_for_status() %>%
    httr::content(.)

  if (parse == FALSE) {
    return(out)
  }
  out %>% xml2::as_list(.)
}


# Tests
# usethis::edit_file("tests/testthat/test-form_xml.R")
