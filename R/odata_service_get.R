#' Retrieve service metadata from an OData URL ending in .svc as tibble.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row per submission data endpoint.
#'         Columns: name, kind, url.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-odata-endpoints/#service-document}
# nolint end
#' @family odata-api
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' svc <- odata_service_get()
#' svc
#' }
odata_service_get <- function(pid = get_default_pid(),
                              fid = get_default_fid(),
                              url = get_default_url(),
                              un = get_default_un(),
                              pw = get_default_pw(),
                              retries = get_retries()) {
  yell_if_missing(url, un, pw)
  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}.svc"
      )
    ),
    httr::add_headers(Accept = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    magrittr::extract2("value") %>%
    { # nolint
      tibble::tibble(
        name = purrr::map_chr(., "name"),
        kind = purrr::map_chr(., "kind"),
        url = purrr::map_chr(., "url")
      )
    }
}

# usethis::use_test("odata_service_get") # nolint
