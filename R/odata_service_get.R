#' Retrieve service metadata from an OData URL ending in .svc as list of lists
#'
#' @template param-pid
#' @template param-fid
#' @template param-auth
#' @return A tibble with one row per submission data endpoint.
#'         Columns: name, kind, url.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/service-document}
#' @family odata-api
#' @importFrom httr add_headers authenticate content GET
#' @importFrom magrittr extract2
#' @importFrom purrr map_chr
#' @importFrom tibble tibble
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
#' svc <- odata_service_get(pid, fid)
#'
#' # With explicitly set credentials
#' svc <- odata_service_get(pid, fid, url = url, un = un, pw = pw)
#' svc
#' }
odata_service_get <- function(pid,
                              fid,
                              url = Sys.getenv("ODKC_URL"),
                              un = Sys.getenv("ODKC_UN"),
                              pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}.svc") %>%
    httr::GET(
      httr::add_headers(Accept = "application/json"),
      httr::authenticate(un, pw)
    ) %>%
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
