#' Split a column of a dataframe containing WKT POINT into lat, lon, alt.
#'
#' @param data (dataframe) A dataframe with a column of type WKT POINT
#' @param colname (chr) The name of the WKT POINT column
#' @return The given dataframe with the WKT POINT column <cn> replaced by three
#'   columns, `<colname>_latitude`, `<colname>_longitude`, `<colname>_altitude`.
#'   The three new columns are prefixed with the original `colname` to avoid
#'   naming conflicts with possible other geopoint columns.
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
#' names(df_split) == c(
#'   "stuff", "loc_latitude", "loc_longitude", "loc_altitude"
#' )
split_geopoint <- function(data, colname) {
  lon <- glue::glue("{colname}_longitude") %>% as.character()
  lat <- glue::glue("{colname}_latitude") %>% as.character()
  alt <- glue::glue("{colname}_altitude") %>% as.character()

  data %>%
    tidyr::extract(
      colname,
      c(lon, lat, alt),
      "POINT \\(([^,]+) ([^)]+) ([^,]+)\\)",
      convert = TRUE
    )
}

# Tests
# usethis::use_test("split_geopoint")
