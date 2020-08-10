#' Drop any NULL coordinates from a GeoJSON geometry.
#'
#' This helper patches a bug/feature in ODK Central (versions 0.7-0.9), where
#' geotrace / geoshape GeoJSON contains a last coordinate pair with NULL
#' lat/lon (no alt/acc), and WKT ends in `, undefined NaN`.
#'
#' While \code{\link{split_geotrace}} and \code{\link{split_geoshape}} modify
#' the WKT inline, it is more maintainable to separate the GeoJSON cleaner
#' into this function.
#'
#' This helper drops the last element of a GeoJSON coordinate list if it is
#' `list(NULL, NULL)`.
#'
#' @param x A GeoJSON geometry parsed as nested list.
#'   E.g. `geo_gj$path_location_path_gps`.
#' @return The nested list minus the last element (if NULL).
#' @family utilities
#' @export
#' @examples
#' # A snapshot of geo data with trailing empty coordinates.
#' data("geo_gj88")
#'
#' len_coords <- length(geo_gj88$path_location_path_gps[[1]]$coordinates)
#'
#' length(geo_gj88$path_location_path_gps[[1]]$coordinates[[len_coords]]) %>%
#'   testthat::expect_equal(2)
#'
#' geo_gj88$path_location_path_gps[[1]]$coordinates[[len_coords]][[1]] %>%
#'   testthat::expect_null()
#'
#' geo_gj88$path_location_path_gps[[1]]$coordinates[[len_coords]][[2]] %>%
#'   testthat::expect_null()
#'
#' # The last coordinate pair is a list(NULL, NULL).
#' # Invalid coordinates like these are a choking hazard for geospatial
#' # packages. We should remove them before we can convert ODK data into native
#' # spatial formats, such as sf.
#' str(geo_gj88$path_location_path_gps[[1]]$coordinates[[len_coords]])
#'
#' geo_gj_repaired <- geo_gj88 %>%
#'   dplyr::mutate(
#'     path_location_path_gps = path_location_path_gps %>%
#'       purrr::map(drop_null_coords)
#'   )
#'
#' len_coords_repaired <- length(
#'   geo_gj_repaired$path_location_path_gps[[1]]$coordinates
#' )
#' testthat::expect_equal(len_coords_repaired + 1, len_coords)
drop_null_coords <- function(x) {
  # Extract and simplify last coords. list(NULL, NULL) becomes list().
  xx <- purrr::compact(x$coordinates[[length(x$coordinates)]])
  # Remove empty coords by setting the entire list(NULL, NULL) to NULL.
  if (is.list(xx) && length(xx) == 0) {
    x$coordinates[[length(x$coordinates)]] <- NULL
  }
  x
}

# usethis::use_test("drop_null_coords")  # nolint
