#' Split a column of a dataframe containing a Geotrace into lon, lat, alt.
#'
#' \lifecycle{stable}
#'
#' @details This function is used by \code{\link{handle_ru_geopoints}}
#' on all \code{geopoint} fields as per \code{\link{form_schema}}.
#'
#' @param data (dataframe) A dataframe with a geotrace column.
#' @param colname (chr) The name of the geotrace column.
#'   This column will be retained.
#' @template param-wkt
#' @return The given dataframe with the geotrace column <colname>, plus
#'   three new columns, `<colname>_longitude`, `<colname>_latitude`,
#'   `<colname>_altitude`.
#'   The three new columns are prefixed with the original `colname` to avoid
#'   naming conflicts with any other geotrace columns.
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' library(magrittr)
#' data("gep_fs")
#' data("geo_wkt_raw")
#' data("geo_gj_raw")
#'
#' # Find variable names of geotraces
#' geo_fields <- geo_fs %>%
#'   dplyr::filter(type  == "geotrace") %>%
#'   magrittr::extract2("ruodk_name")
#' geo_fields[1] # First geotrace in data: path_location_path_gps
#'
#' # Rectangle but don't parse submission data (GeoJSON and WKT)
#' geo_gj_rt <- geo_gj_raw %>%
#'   odata_submission_rectangle(form_schema = geo_fs)
#' geo_wkt_rt <- geo_wkt_raw %>%
#'   odata_submission_rectangle(form_schema = geo_fs)
#'
#' # Data with first geotrace split
#' gj_first_gt <- split_geotrace(geo_gj_rt, geo_fields[1], wkt = FALSE)
#' testthat::expect_true(
#'   "path_location_path_gps_longitude" %in% names(gj_first_gt))
#' testthat::expect_true(
#'   "path_location_path_gps_latitude" %in% names(gj_first_gt))
#' testthat::expect_true(
#'   "path_location_path_gps_altitude" %in% names(gj_first_gt))
#' testthat::expect_true(
#'   is.numeric(gj_first_gt$path_location_path_gps_longitude))
#' testthat::expect_true(
#'   is.numeric(gj_first_gt$path_location_path_gps_latitude))
#' testthat::expect_true(
#'   is.numeric(gj_first_gt$path_location_path_gps_altitude))
#'
#' wkt_first_gt <- split_geotrace(geo_wkt_rt, geo_fields[1], wkt = TRUE)
#' testthat::expect_true(
#'   "path_location_path_gps_longitude" %in% names(wkt_first_gt)
#' )
#' testthat::expect_true(
#'   "path_location_path_gps_latitude" %in% names(wkt_first_gt)
#' )
#' testthat::expect_true(
#'   "path_location_path_gps_altitude" %in% names(wkt_first_gt)
#' )
#' testthat::expect_true(
#'   is.numeric(wkt_first_gt$path_location_path_gps_longitude)
#' )
#' testthat::expect_true(
#'   is.numeric(wkt_first_gt$path_location_path_gps_latitude)
#' )
#' testthat::expect_true(
#'   is.numeric(wkt_first_gt$path_location_path_gps_altitude)
#' )
#' }
split_geotrace <- function(data, colname, wkt = FALSE) {
  if (wkt == FALSE) {
    # GeoJSON
    # Task: Extract coordinates into programmatically generated variable names
    # Step 1: tidyr::hoist() extracts but can't assign with :=
    data %>%
      tidyr::hoist(
        colname,
        XXX_longitude = list("coordinates", 1L, 1L),
        XXX_latitude = list("coordinates", 1L, 2L),
        XXX_altitude = list("coordinates", 1L, 3L),
        # GeoJSON linestring has no accuracy
        .remove = FALSE
      ) %>%
      # Step 2: dplyr::mutate_at() can programmatically manipulate variables
      dplyr::rename_at(
        dplyr::vars(dplyr::starts_with("XXX")),
        list( ~ stringr::str_replace(., "XXX", colname))
      )
  } else{
    # WKT
    data %>%
      tidyr::extract(
        colname,
        c(
          glue::glue("{colname}_longitude") %>% as.character(),
          glue::glue("{colname}_latitude") %>% as.character(),
          glue::glue("{colname}_altitude") %>% as.character()
        ),
        "LINESTRING \\(([0-9\\.\\-]+) ([0-9\\.\\-]+) ([0-9\\.\\-]+)",
        remove = FALSE,
        convert = TRUE
      )
  }
}


# usethis::use_test("split_geotrace")