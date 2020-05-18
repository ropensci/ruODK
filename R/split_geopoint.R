#' Split a column of a dataframe containing a WKT POINT into lon, lat, alt.
#'
#' \lifecycle{stable}
#'
#' @details This function is used by \code{\link{handle_ru_geopoints}}
#' on all \code{geopoint} fields as per \code{\link{form_schema}}.
#'
#' @param data (dataframe) A dataframe with a column of type WKT POINT
#' @param colname (chr) The name of the WKT POINT column.
#'   This column will be retained.
#' @return The given dataframe with the WKT POINT column <colname>, plus
#'   three new columns, `<colname>_longitude`, `<colname>_latitude`,
#'   `<colname>_altitude`.
#'   The three new columns are prefixed with the original `colname` to avoid
#'   naming conflicts with any other geopoint columns.
#' @export
#' @family utilities
#' @examples
#' df <- tibble::tibble(
#'   stuff = c("asd", "sdf", "sdf"),
#'   loc = c(
#'     "POINT (115.99 -32.12 20.01)",
#'     "POINT (116.12 -33.34 15.23)",
#'     "POINT (114.00 -31.56 23.56)"
#'   )
#' )
#' df_split <- df %>% split_geopoint("loc")
#' testthat::expect_equal(
#'   names(df_split),
#'   c("stuff", "loc", "loc_longitude", "loc_latitude", "loc_altitude")
#' )
split_geopoint <- function(data, colname, wkt = FALSE) {
  if (wkt == FALSE) {
    # GeoJSON
    # Extract coords into programmatically generated variable names
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
      # Step 2: dplyr::mutate_at() can programmatically manipulate vars
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
        "POINT \\(([^,]+) ([^)]+) ([^,]+)\\)",
        remove = FALSE,
        convert = TRUE
      )
  }
}

# Tests
# usethis::use_test("split_geopoint")
