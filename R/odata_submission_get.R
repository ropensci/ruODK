#' Retrieve /Submissions from an OData URL ending in .svc as list of lists
#'
#'
#' @template param-pid
#' @template param-fid
#' @param table The submission EntityType, or in plain words, the table name.
#'            Default: "Submissions" (the main table).
#'            Change to "Submissions.GROUP_NAME" for repeating form groups.
#'            The group name can be found in the metadata under
#'            DataServices.Schema.[EntityType].Name
#' @param skip The number of rows to be omitted from the results.
#'             Example: 10, default: NA (none skipped).
#' @param top The number of rows to return.
#'            Example: 100, default: NA (all returned).
#' @param count If TRUE, an `@odata.count` property will be returned in the
#'              response from ODK Central. Default: FALSE.
#' @param wkt If TRUE, geospatial data will be returned as WKT (Well Known Text)
#'            strings. Default: FALSE, returns GeoJSON structures.
#' @template param-auth
#' @return A nested list of lists.
#'         `value` contains the submissions, which can be "rectangled" using
#'     `tidyr::unnest_wider("element_name")`.
#'     `@odata.context` is the URL of the metadata.
#'     `@odata.count` is the total number of rows in the table.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service}
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/data-document}
#' @family odata-api
#' @importFrom glue glue
#' @importFrom httr add_headers authenticate content GET
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup", package = "ruODK")
#' data <- odata_submissions_get(
#'   get_test_pid(),
#'   get_test_fid(),
#'   table = "Submissions"
#' )
#'
#' # With explicitly set credentials
#' data <- odata_submissions_get(
#'   get_test_pid(),
#'   get_test_fid(),
#'   table = "Submissions",
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' # Skip one row, return the next 1 rows (top), include total row count
#' data <- odata_submissions_get(
#'   get_test_pid(),
#'   get_test_fid(),
#'   table = "Submissions",
#'   skip = 1,
#'   top = 1,
#'   count = TRUE,
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' # Parse point coordinates into lat, lon, alt
#' data <- odata_submissions_get(
#'   get_test_pid(),
#'   get_test_fid(),
#'   table = "Submissions",
#'   wkt = FALSE,
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' # Parse point coordinates into WKT like "POINT (115.8840312 -31.9961844 0)"
#' data <- odata_submissions_get(
#'   get_test_pid(),
#'   get_test_fid(),
#'   table = "Submissions",
#'   wkt = TRUE,
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' listviewer::jsonedit(data)
#'
#' # Next: parse this nested list in to a tidy tibble with `parse_submissions`
#' }
odata_submission_get <- function(pid,
                                 fid,
                                 table = "Submissions",
                                 skip = NA,
                                 top = NA,
                                 count = FALSE,
                                 wkt = FALSE,
                                 url = get_default_url(),
                                 un = get_default_un(),
                                 pw = get_default_pw()) {
  . <- NULL
  yell_if_missing(url, un, pw)

  # Parse params
  if (is.na(skip)) skip <- ""
  if (is.na(top)) top <- ""
  if (count == FALSE) {
    count <- "false"
  } else {
    count <- "true"
  }
  if (wkt == FALSE) {
    wkt <- "false"
  } else {
    wkt <- "true"
  }

  # Get submissions
  glue::glue(
    "{url}/v1/projects/{pid}/forms/{fid}.svc/{table}",
    "?$skip={skip}&$top={top}&$count={count}&$wkt={wkt}"
  ) %>%
    httr::GET(
      httr::add_headers(Accept = "application/json"),
      httr::authenticate(un, pw)
    ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.)
}

# Tests
# usethis::edit_file("tests/testthat/test-odata_submission_get.R")
