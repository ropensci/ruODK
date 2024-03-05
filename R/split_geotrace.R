#' Annotate a dataframe containing a geotrace column with lon, lat, alt of the
#' geotrace's first point.
#'
#' `r lifecycle::badge("stable")`
#'
#' @details This function is used by \code{\link{handle_ru_geopoints}}
#' on all \code{geopoint} fields as per \code{\link{form_schema}}.
#'
#' The format of the geotrace (GeoJSON, WKT, ODK Linestring) is determined via
#' parameters `wkt` and `odkc_version`, rather than inferred from the class of
#' the column. ODK Linestrings are character vectors without a leading
#' "LINESTRING (", WKT are character vectors with a leading "LINESTRING (",
#' and GeoJSON are list columns.
#'
#' @param data (dataframe) A dataframe with a geotrace column.
#' @param colname (chr) The name of the geotrace column.
#'   This column will be retained.
#' @template param-wkt
#' @template param-odkcv
#' @return The given dataframe with the geotrace column colname, plus
#'   three new columns, \code{colname_longitude}, \code{colname_latitude},
#'   \code{colname_altitude}.
#'   The three new columns are prefixed with the original \code{colname} to
#'   avoid naming conflicts with any other geotrace columns.
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' library(magrittr)
#' data("geo_fs")
#' data("geo_wkt_raw")
#' data("geo_gj_raw")
#'
#' # Find variable names of geotraces
#' geo_fields <- geo_fs %>%
#'   dplyr::filter(type == "geotrace") %>%
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
#'   "path_location_path_gps_longitude" %in% names(gj_first_gt)
#' )
#' testthat::expect_true(
#'   "path_location_path_gps_latitude" %in% names(gj_first_gt)
#' )
#' testthat::expect_true(
#'   "path_location_path_gps_altitude" %in% names(gj_first_gt)
#' )
#' testthat::expect_true(
#'   is.numeric(gj_first_gt$path_location_path_gps_longitude)
#' )
#' testthat::expect_true(
#'   is.numeric(gj_first_gt$path_location_path_gps_latitude)
#' )
#' testthat::expect_true(
#'   is.numeric(gj_first_gt$path_location_path_gps_altitude)
#' )
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
split_geotrace <- function(data,
                           colname,
                           wkt = FALSE,
                           odkc_version = get_default_odkc_version()) {
  if (nrow(data) == 0) {
    # Option 1: Early exit - nothing to do
    return(data)
  } else if (semver_lt(odkc_version, "0.8.0")) {
    # odkc_version < 0.8
    # nolint start
    # Option 2: ODK linestring
    # ODK Central <=0.7 ignores the WKT argument for geotrace and geoshape
    # ruODK::odata_submission_get(wkt = TRUE, parse = TRUE)
    # ruODK::odata_submission_get(wkt = FALSE, parse = FALSE) %>%
    # ruODK::odata_submission_rectangle()
    # First three points shown with truncated decimal places
    # v7gt <- "-14.8 128.4 10.9 5.9;-14.9 128.5 1.7 1.9;-15.0 128.6 1.9 1.7;"
    # nolint end
    data %>%
      tidyr::extract(
        dplyr::all_of(colname),
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
    # Option 3: ODKC V0.8 GeoJSON
    # Task: Extract coordinates into programmatically generated variable names
    # Step 1: tidyr::hoist() extracts but can't assign with :=
    data %>%
      tidyr::hoist(
        dplyr::all_of(colname),
        XXX_longitude = list("coordinates", 1L, 1L),
        XXX_latitude = list("coordinates", 1L, 2L),
        XXX_altitude = list("coordinates", 1L, 3L),
        # GeoJSON linestring has no accuracy
        .remove = FALSE
      ) %>%
      # Step 2: dplyr::mutate_at() can programmatically manipulate variables
      dplyr::rename_at(
        dplyr::vars(dplyr::any_of(dplyr::starts_with("XXX"))),
        list(~ stringr::str_replace(., "XXX", colname))
      ) %>%
      # Drop last empty coordinate from colname, a list(NULL, NULL).
      # Affects ODK Central Version 0.7-0.9.
      dplyr::mutate_at(
        dplyr::vars(dplyr::all_of(colname)),
        list(~ purrr::map(., drop_null_coords))
      )
  } else {
    # Option 4: ODKC v0.8 WKT
    data %>%
      tidyr::extract(
        dplyr::all_of(colname),
        c(
          glue::glue("{colname}_longitude") %>% as.character(),
          glue::glue("{colname}_latitude") %>% as.character(),
          glue::glue("{colname}_altitude") %>% as.character()
        ),
        "LINESTRING \\(([0-9\\.\\-]+) ([0-9\\.\\-]+) ([0-9\\.\\-]+)",
        remove = FALSE,
        convert = TRUE
      ) %>%
      dplyr::mutate_at(
        dplyr::vars(dplyr::all_of(colname)),
        list(~ stringr::str_replace_all(., ",undefined NaN", ""))
      )
  }
}

# usethis::use_test("split_geotrace") # nolint
