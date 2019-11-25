#' Retrieve service metadata from an OData URL ending in .svc as list of lists
#'
#' \lifecycle{stable}
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @return A tibble with one row per submission data endpoint.
#'         Columns: name, kind, url.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/service-document}
# nolint end
#' @family odata-api
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
#' svc <- odata_service_get()
#' svc
#' }
odata_service_get <- function(pid = get_default_pid(),
                              fid = get_default_fid(),
                              url = get_default_url(),
                              un = get_default_un(),
                              pw = get_default_pw()) {
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
