#' Retrieve metadata from an OData URL ending in .svc as list of lists
#'
#' @template param-pid
#' @template param-fid
#' @template param-auth
#' @return A nested list containing Edmx (dataset schema definition) and
#'   .attrs (Version).
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/metadata-document}
#' @family odata-api
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup", package = "ruODK")
#' meta <- odata_metadata_get(
#'   get_test_pid(),
#'   get_test_fid()
#' )
#'
#' # With explicitly set credentials
#' meta <- odata_metadata_get(
#'   get_test_pid(),
#'   get_test_fid(),
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' listviewer::jsonedit(meta)
#' }
odata_metadata_get <- function(pid,
                               fid,
                               url = get_default_url(),
                               un = get_default_un(),
                               pw = get_default_pw()) {
  . <- NULL
  yell_if_missing(url, un, pw)
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}.svc/$metadata") %>%
    httr::GET(
      httr::add_headers(Accept = "application/xml"),
      httr::authenticate(un, pw)
    ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    xml2::as_list(.)
}

# Tests
# usethis::edit_file("tests/testthat/test-odata_metadata_get.R")
