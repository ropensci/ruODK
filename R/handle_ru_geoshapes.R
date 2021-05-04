#' Split all geoshapes of a submission tibble into their components.
#'
#' `r lifecycle::badge("stable")`
#'
#' @details For a given tibble of submissions, find all columns which are listed
#' in the form schema as type \code{geoshape}, and extract their components.
#' Extracted components are longitude (X), latitude (Y), altitude (Z, where
#' given), and accuracy (M, where given) of the first point of the geoshape.
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
#' @return The submissions tibble with all geoshapes retained in their original
#'   format, plus columns of their first point's coordinate components as
#'   provided by \code{\link{split_geoshape}}.
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' library(magrittr)
#' data("geo_fs")
#' data("geo_wkt_raw")
#' data("geo_gj_raw")
#'
#' # GeoJSON
#' geo_gj_parsed <- geo_gj_raw %>%
#'   ruODK::odata_submission_rectangle(form_schema = geo_fs) %>%
#'   ruODK::handle_ru_geoshapes(form_schema = geo_fs, wkt = FALSE)
#'
#' dplyr::glimpse(geo_gj_parsed)
#'
#' # WKT
#' geo_wkt_parsed <- geo_wkt_raw %>%
#'   ruODK::odata_submission_rectangle(form_schema = geo_fs) %>%
#'   ruODK::handle_ru_geoshapes(form_schema = geo_fs, wkt = TRUE)
#'
#' dplyr::glimpse(geo_wkt_parsed)
#' }
handle_ru_geoshapes <- function(data,
                                form_schema,
                                wkt = FALSE,
                                odkc_version = get_default_odkc_version(),
                                verbose = get_ru_verbose()) {
  # Find geoshape columns
  geo_cols <- form_schema %>%
    dplyr::filter(type == "geoshape") %>%
    magrittr::extract2("ruodk_name") %>%
    intersect(names(data))

  x <- paste(geo_cols, collapse = ", ") # nolint
  "Found geoshapes: {x}." %>%
    glue::glue() %>%
    ru_msg_info(verbose = verbose)


  for (colname in geo_cols) {
    if (colname %in% names(data)) {
      "Parsing {colname}..." %>%
        glue::glue() %>%
        ru_msg_info(verbose = verbose)
      data <- data %>% split_geoshape(
        as.character(colname),
        wkt = wkt,
        odkc_version = odkc_version
      )
    }
  }

  data
}

# usethis::use_test("handle_ru_geoshapes") # nolint
