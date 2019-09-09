#' Retrieve /Submissions from an OData URL ending in .svc as list of lists
#'
#'
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
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @return A nested list of lists.
#'         `value` contains the submissions, which can be "rectangled" using
#'     `tidyr::unnest_wider("element_name")`.
#'     `@odata.context` is the URL of the metadata.
#'     `@odata.count` is the total number of rows in the table.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service}
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/data-document}
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
#' data <- odata_submissions_get(table = "Submissions")
#'
#' # Skip one row, return the next 1 rows (top), include total row count
#' data <- odata_submissions_get(
#'   table = "Submissions",
#'   skip = 1,
#'   top = 1,
#'   count = TRUE
#' )
#'
#' # Parse point coordinates into lat, lon, alt
#' data <- odata_submissions_get(
#'   table = "Submissions",
#'   wkt = FALSE
#' )
#'
#' # Parse point coordinates into WKT like "POINT (115.8840312 -31.9961844 0)"
#' data <- odata_submissions_get(
#'   table = "Submissions",
#'   wkt = TRUE
#' )
#'
#' listviewer::jsonedit(data)
#'
#' # Next: parse this nested list in to a tidy tibble with `parse_submissions`
#' }
odata_submission_get <- function(table = "Submissions",
                                 skip = NA,
                                 top = NA,
                                 count = FALSE,
                                 wkt = FALSE,
                                 pid = get_default_pid(),
                                 fid = get_default_fid(),
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
