#' Retrieve form submissions, parse data and dates, download and link
#' attachments.
#'
#' \lifecycle{maturing}
#'
#' @details \code{\link{odata_submission_get}} downloads submissions from
#' (default) the main form group (submission table) including any non-repeating
#' form groups, or from any other table as specified by parameter `table`.
#'
#'
#' With parameter `parse=TRUE` (default), submission data is parsed into a
#' tibble. Any fields of type `dateTime`` or `date`` are parsed into dates, with
#' an optional parameter `tz` to specify the local timezone.
#' A parameter `local_dir` (default: "media") specifies a local directory for
#' downloaded attachment files. Already existing, previously downloaded
#' attachments will be retained. The only remaining manual step is to optionally
#' rename any point location coordinate parts into `latitude`, `longitude`,
#' `altitude`, and `accuracy`, as well as to join subtables to the master table.
#' The parameter `verbose` enables diagnostic messages along the download and
#' parsing process.
#'
#' With parameter `wkt=TRUE`, spatial fields will be returned as WKT, rather
#' than GeoJSON. In addition, fields of type `geopoint` will be split into
#' latitude, longitude, and altitude, prefixed with the original field name.
#' E.g. a field `start_location` of type `geopoint` will be split into
#' `start_location_latitude`, `start_location_longitude`, and
#' `start_location_altitude`. The field name prefix will allow multiple fields
#' of type `geopoint` to be split into their components without naming
#' conflicts. Other spatial fields will be retained as WKT.
#'
#' With parameter `parse=FALSE`, submission data is presented as nested list,
#' which is the R equivalent of the returned form JSON.
#' From there, \code{\link{odata_submission_parse}} will parse the data into a
#' tibble, and subsequent lines of \code{\link{ru_datetime}} and
#' \code{\link{attachment_get}} parse dates and download and link file
#' attachments.
#' As any of these steps might fail on unexpected errors, `ruODK` offers this
#' longer, more manual pathway as an option to investigate and narrow down
#' unexpected or unwanted behaviour.
#'
#' @param table The submission EntityType, or in plain words, the table name.
#'   Default: "Submissions" (the main table).
#'   Change to "Submissions.GROUP_NAME" for repeating form groups.
#'   The group name can be found through \code{\link{odata_service_get}}.
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
#'   ruODK parses `geopoint` WKT into latitude, longitude, and altitude,
#'   prefixed by the original field name to avoid naming conflicts.
#' @param parse Whether to parse submission data based on form schema.
#'   Dates and datetimes will be parsed into local time.
#'   Attachments will be downloaded, and the field updated to the local file
#'   path.
#'   Point locations will be split into components; GeoJSON (`wkt=FALSE`) will
#'   be split into latitude, longitude, altitude and accuracy (with anonymous
#'   field names), while WKT will be split into latitude, longitude, and
#'   altitude (missing accuracy) prefixed by the original field name.
#'   Default: TRUE.
#' @template param-verbose
#' @param orders (vector of character) Orders of datetime elements for
#'   lubridate.
#'   Default:
#'   \code{c("YmdHMS", "YmdHMSz", "Ymd HMS", "Ymd HMSz", "Ymd", "ymd")}.
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
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service}
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/odata-endpoints/odata-form-service/data-document}
# nolint end
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
#' data <- odata_submission_get() # default: main data table
#' data <- odata_submission_get(table = form_tables$url[1]) # same, explicitly
#' data_sub1 <- odata_submission_get(table = form_tables$url[2]) # sub-table 1
#' data_sub2 <- odata_submission_get(table = form_tables$url[3]) # sub-table 2
#'
#' # Skip one row, return the next 1 rows (top), include total row count
#' data <- odata_submission_get(
#'   table = form_tables$url[1],
#'   skip = 1,
#'   top = 1,
#'   count = TRUE
#' )
#'
#' # Point coordinates (lat, lon, alt, acc) need to be renamed
#' data <- odata_submission_get(
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
#' data <- odata_submission_get(
#'   table = form_tables$url[1],
#'   wkt = TRUE
#' )
#' # Columns of type "geopoint" will be split into lat lon alt (no accuracy) and
#' # prefixed with the ODK geopoint field name. Use parse=FALSE to retain WKT.
#' # Columns of other spatial types will remain WKT.
#' }
odata_submission_get <- function(table = "Submissions",
                                 skip = NULL,
                                 top = NULL,
                                 count = FALSE,
                                 wkt = FALSE,
                                 parse = TRUE,
                                 verbose = FALSE,
                                 orders = c(
                                   "YmdHMS",
                                   "YmdHMSz",
                                   "Ymd HMS",
                                   "Ymd HMSz",
                                   "Ymd",
                                   "ymd"
                                 ),
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
  if (verbose == TRUE) {
    message(crayon::cyan(
      glue::glue("{clisymbols::symbol$info}",
                 " Downloading submissions...\n")
    ))
  }

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
    message(crayon::green(
      glue::glue("{clisymbols::symbol$tick}",
      " Downloaded {length(sub)} submissions.\n")
    ))
  }

  if (parse == FALSE) {
    return(sub)
  } else{
    if (verbose == TRUE) {
      message(crayon::cyan(
        glue::glue("{clisymbols::symbol$info}",
                   " Parsing submissions...\n")
      ))
    }
  }

  #----------------------------------------------------------------------------#
  # Get form schema
  if (verbose == TRUE) {
    message(crayon::cyan(
      glue::glue("{clisymbols::symbol$info} Reading form schema...\n")
    ))
  }

  fs <- form_schema(
    parse = TRUE,
    pid = pid,
    fid = fid,
    url = url,
    un = un,
    pw = pw
  )

  #----------------------------------------------------------------------------#
  # Parse submission data
  if (verbose == TRUE) {
    message(crayon::cyan(
      glue::glue("{clisymbols::symbol$info} Parsing submissions...\n")
    ))
  }
  sub <- sub %>% odata_submission_parse(form_schema = fs, verbose = verbose)



  # Parse dates
  dttm_cols <- fs %>%
    dplyr::filter(type %in% c("dateTime", "date")) %>%
    magrittr::extract2("name")

  if (verbose == TRUE) {
    message(crayon::cyan(
      glue::glue("{clisymbols::symbol$info}",
                 " Found date/time: \"{dttm_cols}\". \n")
    ))
  }


  for (colname in dttm_cols) {
    if (verbose == TRUE) {
      if (verbose == TRUE) {
        message(crayon::cyan(
          glue::glue("{clisymbols::symbol$info}",
                     " Parsing \"{colname}\" with timezone \"{tz}\"...\n")
        ))
      }
    }
    sub <- sub %>%
      ruODK::ru_datetime(
        orders = orders,
        tz = tz,
        col_contains = as.character(colname)
      )
  }

  # Download and link attachments
  # Caveat: if an attachment field has no submissions, it is dropped from sub
  att_cols <- fs %>%
    dplyr::filter(type == "binary") %>%
    magrittr::extract2("name") %>%
    intersect(names(sub))

  if (verbose == TRUE) {
    if (verbose == TRUE) {
      message(crayon::cyan(
        glue::glue("{clisymbols::symbol$info}",
                   " Found attachments: \"{att_cols}\". \n")
      ))
      message(crayon::green(
        glue::glue("{clisymbols::symbol$tick}",
                   " Downloading attachments...\n")
      ))
    }

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

  # Parse geopoints (already split into e.g. x10 x11 x12 if wkt="false")
  if (wkt == "true") {
    gp_cols <- fs %>%
      dplyr::filter(type == "geopoint") %>%
      magrittr::extract2("name")

    if (verbose == TRUE) {
      message(crayon::cyan(
        glue::glue("{clisymbols::symbol$info}",
                   " Found geopoint: \"{gp_cols}\". \n")
      ))
    }

    for (colname in gp_cols) {
      if (colname %in% names(sub)) {
        if (verbose == TRUE) {
          message(crayon::cyan(
            glue::glue("{clisymbols::symbol$info}",
                       " Parsing {colname}...\n")
          ))
        }

        sub <- sub %>% split_geopoint(as.character(colname))
      }
    }
  }

  #
  # End parse submission data
  #----------------------------------------------------------------------------#
  if (verbose == TRUE) {
    message(crayon::green(
      glue::glue("{clisymbols::symbol$tick}",
                 " Returning parsed submissions.\n")
    ))
  }
  sub
}

# Tests

# usethis::edit_file("tests/testthat/test-odata_submission_get.R")
