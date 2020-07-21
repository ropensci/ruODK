#' Split all geotraces of a submission tibble into their components.
#'
#' \lifecycle{stable}
#'
#' @details For a given tibble of submissions, find all columns which are listed
#' in the form schema as type \code{geotrace}, and extract their components.
#' Extracted components are longitude (X), latitude (Y), altitude (Z, where
#' given), and accuracy (M, where given) of the first point of the geotrace.
#'
#' The original column is retained to allow parsing into other spatially
#' enabled formats.
#' @param data Submissions rectangled into a tibble. E.g. the output of
#'   ```
#'   ruODK::odata_submission_get(parse = FALSE) %>%
#'   ruODK::odata_submission_rectangle(form_schema = ...)
#'   ```
#' @param form_schema The `form_schema` for the submissions.
#'   E.g. the output of `ruODK::form_schema()`.
#' @template param-wkt
#' @template param-odkcv
#' @template param-verbose
#' @return The submissions tibble with all geotraces retained in their original
#'   format, plus columns of their first point's coordinate components as
#'   provided by \code{\link{split_geotrace}}.
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' library(magrittr)
#' data("gep_fs")
#' data("geo_wkt_raw")
#' data("geo_gj_raw")
#'
#' # GeoJSON
#' geo_gj_parsed <- geo_gj_raw %>%
#'   ruODK::odata_submission_rectangle(form_schema = geo_fs) %>%
#'   ruODK::handle_ru_geotraces(form_schema = geo_fs, wkt = FALSE)
#'
#' dplyr::glimpse(geo_gj_parsed)
#'
#' # WKT
#' geo_wkt_parsed <- geo_wkt_raw %>%
#'   ruODK::odata_submission_rectangle(form_schema = geo_fs) %>%
#'   ruODK::handle_ru_geotraces(form_schema = geo_fs, wkt = TRUE)
#'
#' dplyr::glimpse(geo_wkt_parsed)
#' }
handle_ru_geotraces <- function(data,
                                form_schema,
                                wkt = FALSE,
                                odkc_version = get_default_odkc_version(),
                                verbose = get_ru_verbose()) {
  # Find Geotrace columns
  geo_cols <- form_schema %>%
    dplyr::filter(type == "geotrace") %>%
    magrittr::extract2("ruodk_name") %>%
    intersect(names(data))

  if (verbose == TRUE) {
    x <- paste(geo_cols, collapse = ", ") # nolint
    ru_msg_info(glue::glue("Found geotraces: {x}."))
  }

  for (colname in geo_cols) {
    if (colname %in% names(data)) {
      if (verbose == TRUE) ru_msg_info(glue::glue("Parsing {colname}..."))
      data <- data %>%
        split_geotrace(
          as.character(colname),
          wkt = wkt,
          odkc_version = odkc_version
        )
    }
  }

  data
}

# usethis::use_test("handle_ru_geotraces") # nolint
