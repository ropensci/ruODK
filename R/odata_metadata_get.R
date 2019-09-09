#' Retrieve metadata from an OData URL ending in .svc as list of lists
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @return A nested list containing Edmx (dataset schema definition) and
#'   .attrs (Version).
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/metadata-document}
#' @family odata-api
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-2_1558575936.svc",
#'   un = "me@email.com",
#'   pw = "..."
#' )
#'
#' meta <- odata_metadata_get()
#' listviewer::jsonedit(meta)
#' }
odata_metadata_get <- function(pid = get_default_pid(),
                               fid = get_default_fid(),
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
