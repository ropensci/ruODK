#' Annotate a dataframe containing a geoshape column with lon, lat, alt of the
#' geotrace's first point.
#'
#' \lifecycle{stable}
#'
#' @details This function is used by \code{\link{handle_ru_geopoints}}
#' on all \code{geopoint} fields as per \code{\link{form_schema}}.
#'
#' @param data (dataframe) A dataframe with a geoshape column.
#' @param colname (chr) The name of the geoshape column.
#'   This column will be retained.
#' @template param-wkt
#' @template param-odkcv
#' @return The given dataframe with the geoshape column <colname>, plus
#'   three new columns, \code{<colname>_longitude}, \code{<colname>_latitude},
#'   \code{<colname>_altitude}.
#'   The three new columns are prefixed with the original \code{colname} to
#'   avoid naming conflicts with any other geoshape columns.
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' library(magrittr)
#' data("gep_fs")
#' data("geo_wkt_raw")
#' data("geo_gj_raw")
#'
#' # Find variable names of geoshapes
#' geo_fields <- geo_fs %>%
#'   dplyr::filter(type == "geoshape") %>%
#'   magrittr::extract2("ruodk_name")
#' geo_fields[1] # First geoshape in data: shape_location_shape_gps
#'
#' # Rectangle but don't parse submission data (GeoJSON and WKT)
#' geo_gj_rt <- geo_gj_raw %>%
#'   odata_submission_rectangle(form_schema = geo_fs)
#' geo_wkt_rt <- geo_wkt_raw %>%
#'   odata_submission_rectangle(form_schema = geo_fs)
#'
#' # Data with first geoshape split
#' gj_first_gt <- split_geoshape(geo_gj_rt, geo_fields[1], wkt = FALSE)
#' cn_gj <- names(gj_first_gt)
#' testthat::expect_true("shape_location_shape_gps_longitude" %in% cn_gj)
#' testthat::expect_true("shape_location_shape_gps_latitude" %in% cn_gj)
#' testthat::expect_true("shape_location_shape_gps_altitude" %in% cn_gj)
#' testthat::expect_true(
#'   is.numeric(gj_first_gt$shape_location_shape_gps_longitude)
#' )
#' testthat::expect_true(
#'   is.numeric(gj_first_gt$shape_location_shape_gps_latitude)
#' )
#' testthat::expect_true(
#'   is.numeric(gj_first_gt$shape_location_shape_gps_altitude)
#' )
#'
#' wkt_first_gt <- split_geoshape(geo_wkt_rt, geo_fields[1], wkt = TRUE)
#' cn_wkt <- names(wkt_first_gt)
#' testthat::expect_true("shape_location_shape_gps_longitude" %in% cn_wkt)
#' testthat::expect_true("shape_location_shape_gps_latitude" %in% cn_wkt)
#' testthat::expect_true("shape_location_shape_gps_altitude" %in% cn_wkt)
#' testthat::expect_true(
#'   is.numeric(wkt_first_gt$shape_location_shape_gps_longitude)
#' )
#' testthat::expect_true(
#'   is.numeric(wkt_first_gt$shape_location_shape_gps_latitude)
#' )
#' testthat::expect_true(
#'   is.numeric(wkt_first_gt$shape_location_shape_gps_altitude)
#' )
#' }
split_geoshape <- function(
  data,
  colname,
  wkt = FALSE,
  odkc_version = odkc_version
) {
  if (nrow(data) == 0) {
    # Option 1: Early exit - nothing to do
    return(data)
  } else if (odkc_version < 0.8) {
    # Option 2: ODK linestring
    # ODK Central <=0.7 ignores the WKT argument for geotrace and geoshape
    # nolint start
    # ruODK::odata_submission_get(wkt = TRUE, parse = TRUE)
    # ruODK::odata_submission_get(wkt = FALSE, parse = FALSE) %>%
    # ruODK::odata_submission_rectangle()
    # First three points shown with truncated decimal places
    # v7gt <- "-14.8 128.4 10.9 5.9;-14.9 128.5 1.7 1.9;-15.0 128.6 1.9 1.7;"
    # nolint end
    data %>%
      tidyr::extract(
        colname,
        c(
          glue::glue("{colname}_latitude") %>% as.character(),
          glue::glue("{colname}_longitude") %>% as.character(),
          glue::glue("{colname}_altitude") %>% as.character()
        ),
        "([0-9\\.\\-]+) ([0-9\\.\\-]+) ([0-9\\.\\-]+)",
        remove = FALSE,
        convert = TRUE
      )
  } else if (wkt == FALSE) {
    # GeoJSON
    # Task: Extract coordinates into programmatically generated variable names
    # Step 1: tidyr::hoist() extracts but can't assign with :=
    data %>%
      tidyr::hoist(
        colname,
        XXX_longitude = list("coordinates", 1L, 1L),
        XXX_latitude = list("coordinates", 1L, 2L),
        XXX_altitude = list("coordinates", 1L, 3L),
        # GeoJSON polygon has no accuracy
        .remove = FALSE
      ) %>%
      # Step 2: dplyr::mutate_at() can programmatically manipulate variables
      dplyr::rename_at(
        dplyr::vars(dplyr::starts_with("XXX")),
        list(~ stringr::str_replace(., "XXX", colname))
      )
  } else {
    # WKT
    data %>%
      tidyr::extract(
        colname,
        c(
          glue::glue("{colname}_longitude") %>% as.character(),
          glue::glue("{colname}_latitude") %>% as.character(),
          glue::glue("{colname}_altitude") %>% as.character()
        ),
        "POLYGON \\(\\(([0-9\\.\\-]+) ([0-9\\.\\-]+) ([0-9\\.\\-]+)",
        remove = FALSE,
        convert = TRUE
      )
  }
}

# usethis::use_test("split_geoshape") # nolint
