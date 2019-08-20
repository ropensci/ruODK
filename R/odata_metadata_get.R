#' Retrieve metadata from an OData URL ending in .svc as list of lists
#'
#' @template param-pid
#' @template param-fid
#' @template param-auth
#' @return A nested list containing DataServices and .attrs (Version).
#'         DataServices contains the dataset definition.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/metadata-document}
#' @family odata-api
#' @importFrom httr add_headers authenticate content GET
#' @importFrom xml2 as_list
#' @export
#' @examples
#' \dontrun{
#' # Replace with your own working url, pid, fid, credentials:
#' pid <- Sys.getenv("ODKC_TEST_PID")
#' fid <- Sys.getenv("ODKC_TEST_FID")
#' url <- Sys.getenv("ODKC_TEST_URL")
#' un <- Sys.getenv("ODKC_TEST_UN")
#' pw <- Sys.getenv("ODKC_TEST_PW")
#'
#' # With default credentials, see vignette("setup", package = "ruODK")
#' meta <- odata_metadata_get(pid, fid)
#'
#' # With explicitly set credentials
#' meta <- odata_metadata_get(pid, fid, url = url, un = un, pw = pw)
#'
#' listviewer::jsonedit(meta)
#' }
odata_metadata_get <- function(pid,
                               fid,
                               url = Sys.getenv("ODKC_URL"),
                               un = Sys.getenv("ODKC_UN"),
                               pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}.svc/$metadata") %>%
    httr::GET(
      httr::add_headers(Accept = "application/xml"),
      httr::authenticate(un, pw)
    ) %>%
    httr::content(.) %>%
    xml2::as_list(.)
}

# Tests
# usethis::edit_file("tests/testthat/test-odata_metadata_get.R")
