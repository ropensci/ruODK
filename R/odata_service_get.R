#' Retrieve service metadata from an OData URL ending in .svc as list of lists
#'
#' @template param-pid
#' @template param-fid
#' @template param-auth
#' @return A tibble with one row per submission data endpoint.
#'         Columns: name, kind, url.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/service-document}
#' @family odata-api
#' @export
#' @examples
#' \dontrun{
#' # Replace with your own working url, pid, fid, credentials:
#' # With default credentials, see vignette("setup", package = "ruODK")
#' svc <- odata_service_get(
#'   get_test_pid(),
#'   get_test_fid()
#' )
#'
#' # With explicitly set credentials
#' svc <- odata_service_get(
#'   get_test_pid(),
#'   get_test_fid(),
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#' svc
#' }
odata_service_get <- function(pid,
                              fid,
                              url = get_default_url(),
                              un = get_default_un(),
                              pw = get_default_pw()) {
  . <- NULL
  yell_if_missing(url, un, pw)
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}.svc") %>%
    httr::GET(
      httr::add_headers(Accept = "application/json"),
      httr::authenticate(un, pw)
    ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    magrittr::extract2("value") %>%
    {
      tibble::tibble(
        name = purrr::map_chr(., c("name")),
        kind = purrr::map_chr(., c("kind")),
        url = purrr::map_chr(., c("url"))
      )
    }
}

# Tests
# usethis::edit_file("tests/testthat/test-odata_service_get.R")
