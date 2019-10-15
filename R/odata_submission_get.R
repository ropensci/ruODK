#' Retrieve form submissions, parse data and dates, download and link
#' attachments.
#'
#' \lifecycle{maturing}
#'
#' @details \code{`odata_submissions_get()`} downloads submissions from
#' (default) the main form group (submission table) including any non-repeating
#' form groups, or from any other table as specified by parameter `table`.
#'
#'
#' With parameter `parse=TRUE` (default), submission data is parsed into a
#' tibble. Any fields of type "dateTime" or "date" are parsed into dates, with
#' an optional parameter `tz` to specify the local timezone.
#' A parameter `local_dir` (default: "media") specifies a local directory for
#' downloaded attachment files. Already existing, previously downloaded
#' attachments will be retained. The only remaining manual step is to optionally
#' rename any point location coordinate parts into "latitude", "longitude",
#' "altitude", and "accuracy", as well as to join subtables to the master table.
#' The parameter `verbose` enables diagnostic messages along the download and
#' parsing process.
#'
#' With parameter `parse=FALSE`, submission data is presented as nested list,
#' which is the R equivalent of the returned form JSON.
#' From there, \code{`odata_submission_parse()`} will parse the data into a
#' tibble, and subsequent lines of \code{`parse_datetime()`} and
#' \code{`attachment_get()`} parse dates and download and link file attachments.
#' As any of these steps might fail on unexpected errors, `ruODK` offers this
#' longer, more manual pathway as an option to investigate and narrow down
#' unexpected or unwanted behaviour.
#'
#' @param table The submission EntityType, or in plain words, the table name.
#'   Default: "Submissions" (the main table).
#'   Change to "Submissions.GROUP_NAME" for repeating form groups.
#'   The group name can be found through \code{`odata_service_get()`}.
#' @param skip The number of rows to be omitted from the results.
#'   Example: 10, default: NA (none skipped).
#' @param top The number of rows to return.
#'   Example: 100, default: NA (all returned).
#' @param count If TRUE, an `@odata.count` property will be returned in the
#'   response from ODK Central. Default: FALSE.
#' @param wkt If TRUE, geospatial data will be returned as WKT (Well Known Text)
#'   strings. Default: FALSE, returns GeoJSON structures.
#'   Note, ODK Central currently only honours this parameter for Point
#'   geometries.
#'   Line and Polygon geometries are returned as "ODK WKT".
#' @param parse Whether to parse submission data based on form schema.
#'   Dates and datetimes will be parsed into local time.
#'   Attachments will be downloaded, and the field updated to the local file
#'   path.
#'   Default: TRUE.
#' @template param-verbose
#' @param tz A timezone, e.g. "Australia/Perth" or "UTC". Default: "UTC".
#' @param local_dir The local folder to save the downloaded files to,
#'   default: "media".
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @return A list of lists.
#'
#'   * `value` contains the submissions as list of lists.
#'   * `@odata.context` is the URL of the metadata.
#'   * `@odata.count` is the total number of rows in the table.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service}
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/data-document}
#' @family odata-api
#' @importFrom rlang %||%
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
#' form_tables <- ruODK::odata_service_get()
#' data <- odata_submissions_get() # default: main data table
#' data <- odata_submissions_get(table = form_tables$url[1]) # same, explicitly
#' data_sub1 <- odata_submissions_get(table = form_tables$url[2]) # sub-table 1
#' data_sub2 <- odata_submissions_get(table = form_tables$url[3]) # sub-table 2
#'
#' # Skip one row, return the next 1 rows (top), include total row count
#' data <- odata_submissions_get(
#'   table = form_tables$url[1],
#'   skip = 1,
#'   top = 1,
#'   count = TRUE
#' )
#'
#' # Point coordinates (lat, lon, alt, acc) need to be renamed
#' data <- odata_submissions_get(
#'   table = form_tables$url[1],
#'   wkt = FALSE
#' ) %>%
#'   dplyr::rename(
#'     # Adjust coordinate colnames as needed
#'     # longitude = x13,
#'     # latitude = x14,
#'     # altitude = x15,
#'     # accuracy = x16
#'   )
#'
#' # Parse point coordinates into WKT like "POINT (115.8840312 -31.9961844 0)"
#' data <- odata_submissions_get(
#'   table = form_tables$url[1],
#'   wkt = TRUE
#' )
#' }
odata_submission_get <- function(table = "Submissions",
                                 skip = NULL,
                                 top = NULL,
                                 count = FALSE,
                                 wkt = FALSE,
                                 parse = TRUE,
                                 verbose = FALSE,
                                 tz = "UTC",
                                 local_dir = "media",
                                 pid = get_default_pid(),
                                 fid = get_default_fid(),
                                 url = get_default_url(),
                                 un = get_default_un(),
                                 pw = get_default_pw()) {
  type <- NULL
  yell_if_missing(url, un, pw)

  # Parse params
  skip <- skip %||% ""
  top <- top %||% ""

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
  if (verbose == TRUE) message("Downloading submissions...\n")

  sub <- glue::glue(
    "{url}/v1/projects/{pid}/forms/{fid}.svc/{table}",
    "?$skip={skip}&$top={top}&$count={count}&$wkt={wkt}"
  ) %>%
    httr::GET(
      httr::add_headers(Accept = "application/json"),
      httr::authenticate(un, pw)
    ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.)

  if (verbose == TRUE) {
    message(glue::glue("Downloaded {length(sub)} submissions.\n"))
  }

  if (parse == FALSE) {
    return(sub)
  }

  #----------------------------------------------------------------------------#
  # Parse submission data
  sub <- sub %>% odata_submission_parse(verbose = verbose)

  # Get form fields
  if (verbose == TRUE) message("Reading form schema...\n")
  fs <- form_schema(
    parse = TRUE,
    pid = pid,
    fid = fid,
    url = url,
    un = un,
    pw = pw
  )

  # Parse dates
  dttm_cols <- fs %>%
    dplyr::filter(type %in% c("dateTime", "date")) %>%
    magrittr::extract2("name")

  if (verbose == TRUE) {
    message(glue::glue("Found date column: {dttm_cols}.\n"))
  }
  for (colname in dttm_cols) {
    if (verbose == TRUE) message(glue::glue("Parsing {colname} as {tz}...\n"))
    sub <- sub %>% parse_datetime(tz = tz, col_contains = as.character(colname))
  }

  # Download and link attachments
  # Caveat: if an attachment field has no submissions, it is dropped from sub
  att_cols <- fs %>%
    dplyr::filter(type == "binary") %>%
    magrittr::extract2("name") %>%
    intersect(names(sub))

  if (verbose == TRUE) {
    message(glue::glue("Downloading attachments...\n"))
  }

  sub <- sub %>% dplyr::mutate_at(
    dplyr::vars(att_cols),
    ~ ruODK::attachment_get(
      id,
      .,
      local_dir = local_dir,
      verbose = verbose,
      pid = pid,
      fid = fid,
      url = url,
      un = un,
      pw = pw
    )
  )

  #
  # End parse submission data
  #----------------------------------------------------------------------------#
  sub
}

# Tests
# usethis::edit_file("tests/testthat/test-odata_submission_get.R")
