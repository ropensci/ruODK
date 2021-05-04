#' Split all geopoints of a submission tibble into their components.
#'
#' `r lifecycle::badge("stable")`
#'
#' @details For a given tibble of submissions, find all columns which are listed
#' in the form schema as type \code{geopoint}, and extract their components.
#' Extracted components are longitude (X), latitude (Y), altitude (Z, where
#' given), and accuracy (M, where given).
#'
#' The original column is retained to allow parsing into other spatially
#' enabled formats.
#' @param data Submissions rectangled into a tibble. E.g. the output of
#'   ```
#'   ruODK::odata_submission_get(parse = FALSE) %>%
#'   ruODK::odata_submission_rectangle()
#'   ```
#' @param form_schema The `form_schema` for the submissions.
#'   E.g. the output of `ruODK::form_schema()`.
#' @template param-wkt
#' @template param-verbose
#' @return The submissions tibble with all geopoints retained in their original
#'   format, plus columns of their coordinate components as provided by
#'   \code{\link{split_geopoint}}.
#' @export
#' @family utilities
#' @examples
#' library(magrittr)
#' data("geo_fs")
#' data("geo_gj_raw")
#' data("geo_wkt_raw")
#'
#' # GeoJSON
#' geo_gj_parsed <- geo_gj_raw %>%
#'   ruODK::odata_submission_rectangle(form_schema = geo_fs) %>%
#'   ruODK::handle_ru_geopoints(form_schema = geo_fs, wkt = FALSE)
#'
#' dplyr::glimpse(geo_gj_parsed)
#'
#' # WKT
#' geo_wkt_parsed <- geo_wkt_raw %>%
#'   ruODK::odata_submission_rectangle(form_schema = geo_fs) %>%
#'   ruODK::handle_ru_geopoints(form_schema = geo_fs, wkt = TRUE)
#'
#' dplyr::glimpse(geo_wkt_parsed)
handle_ru_geopoints <- function(data,
                                form_schema,
                                wkt = FALSE,
                                verbose = get_ru_verbose()) {
  # Find Geopoint columns
  geo_cols <- form_schema %>%
    dplyr::filter(type == "geopoint") %>%
    magrittr::extract2("ruodk_name") %>%
    intersect(names(data))

  x <- paste(geo_cols, collapse = ", ") # nolint
  "Found geopoints: {x}." %>%
    glue::glue() %>%
    ru_msg_info(verbose = verbose)

  for (colname in geo_cols) {
    if (colname %in% names(data)) {
      "Parsing {colname}..." %>%
        glue::glue() %>%
        ru_msg_info(verbose = verbose)
      data <-
        data %>% split_geopoint(as.character(colname), wkt = wkt)
    }
  }

  data
}

# usethis::use_test("handle_ru_geopoints") # nolint
