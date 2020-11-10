#' Annotate a dataframe containing a geopoint column with lon, lat, alt.
#'
#' `r lifecycle::badge("stable")`
#'
#' @details This function is used by \code{\link{handle_ru_geopoints}}
#' on all \code{geopoint} fields as per \code{\link{form_schema}}.
#'
#' @param data (dataframe) A dataframe with a geopoint column.
#' @param colname (chr) The name of the geopoint column.
#'   This column will be retained.
#' @template param-wkt
#' @return The given dataframe with the WKT POINT column <colname>, plus
#'   three new columns, \code{<colname>_longitude}, \code{<colname>_latitude},
#'   \code{<colname>_altitude}.
#'   The three new columns are prefixed with the original \code{colname} to
#'   avoid naming conflicts with any other geopoint columns.
#'
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' df_wkt <- tibble::tibble(
#'   stuff = c("asd", "sdf", "sdf"),
#'   loc = c(
#'     "POINT (115.99 -32.12 20.01)",
#'     "POINT (116.12 -33.34 15.23)",
#'     "POINT (114.01 -31.56 23.56)"
#'   )
#' )
#' df_wkt_split <- df %>% split_geopoint("loc", wkt = TRUE)
#' testthat::expect_equal(
#'   names(df_wkt_split),
#'   c("stuff", "loc", "loc_longitude", "loc_latitude", "loc_altitude")
#' )
#'
#' # With package data
#' data("gep_fs")
#' data("geo_wkt_raw")
#' data("geo_gj_raw")
#'
#' # Find variable names of geopoints
#' geo_fields <- geo_fs %>%
#'   dplyr::filter(type == "geopoint") %>%
#'   magrittr::extract2("ruodk_name")
#' geo_fields[1] # First geotrace in data: point_location_point_gps
#'
#' # Rectangle but don't parse submission data (GeoJSON and WKT)
#' geo_gj_rt <- geo_gj_raw %>%
#'   odata_submission_rectangle(form_schema = geo_fs)
#' geo_wkt_rt <- geo_wkt_raw %>%
#'   odata_submission_rectangle(form_schema = geo_fs)
#'
#' # Data with first geopoint split
#' gj_first_gt <- split_geopoint(geo_gj_rt, geo_fields[1], wkt = FALSE)
#' gj_first_gt$point_location_point_gps_longitude
#'
#' wkt_first_gt <- split_geopoint(geo_wkt_rt, geo_fields[1], wkt = TRUE)
#' wkt_first_gt$point_location_point_gps_longitude
#' }
split_geopoint <- function(data, colname, wkt = FALSE) {
  if (wkt == FALSE) {
    # GeoJSON
    # Task: Extract coordinates into programmatically generated variable names
    # Step 1: tidyr::hoist() extracts but can't assign with :=
    data %>%
      tidyr::hoist(
        colname,
        XXX_longitude = list("coordinates", 1L),
        XXX_latitude = list("coordinates", 2L),
        XXX_altitude = list("coordinates", 3L),
        XXX_accuracy = list("properties", "accuracy"),
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
        "POINT \\(([^,]+) ([^)]+) ([^,]+)\\)",
        remove = FALSE,
        convert = TRUE
      )
  }
}

# usethis::use_test("split_geopoint") # nolint
