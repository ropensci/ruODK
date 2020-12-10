#' Retrieve metadata from an OData URL ending in .svc as list of lists.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A nested list containing Edmx (dataset schema definition) and
#'   .attrs (Version).
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/metadata-document}
# nolint end
#' @family odata-api
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = paste0(
#'     "https://sandbox.central.getodk.org/v1/projects/14/",
#'     "forms/build_Flora-Quadrat-0-2_1558575936.svc"
#'   ),
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
                               pw = get_default_pw(),
                               retries = get_retries()) {
  yell_if_missing(url, un, pw)
  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}.svc/$metadata"
      )
    ),
    httr::add_headers(Accept = "application/xml"),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    xml2::as_list(.)
}

# usethis::use_test("odata_metadata_get") # nolint
