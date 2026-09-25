#' Retrieve metadata from an OData URL ending in .svc as list of lists.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A nested list containing Edmx (Dataset schema definition) and
#'   .attrs (Version).
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-odata-endpoints/#metadata-document}
# nolint end
#' @family odata-api
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' meta <- odata_metadata_get()
#' listviewer::jsonedit(meta)
#' }
odata_metadata_get <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)
  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}.svc/$metadata"
    ),
    accept = "application/xml",
    un = un,
    pw = pw,
    retries = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr2::resp_body_xml() %>%
    xml2::as_list(.)
}

# usethis::use_test("odata_metadata_get") # nolint
