#' Split all WKT geopoints of a submission tibble into their components.
#'
#' \lifecycle{stable}
#'
#' @details For a given tibble of submissions, split WKT geopoints into their
#' components for all columns which are marked in the form schema as type
#' "geopoint".
#' @param data Submissions rectangled into a tibble. E.g. the output of
#'   ```
#'   ruODK::odata_submission_get(parse = FALSE) %>%
#'   ruODK::odata_submission_rectangle()
#'   ```
#' @param form_schema The `form_schema` for the submissions.
#'   E.g. the output of `ruODK::form_schema()`.
#' @template param-verbose
#' @return The submissions tibble with all WKT geopoints split into their
#'   components by \code{\link{split_geopoint}}.
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' library(magrittr)
#' data("fq_raw")
#' data("fq_form_schema")
#'
#' fq_with_geo <- fq_raw %>%
#'   ruODK::odata_submission_rectangle() %>%
#'   ruODK::handle_ru_geopoints(form_schema = fq_form_schema)
#'
#' dplyr::glimpse(fq_with_geo)
#' }
handle_ru_geopoints <- function(data,
                                form_schema,
                                verbose = get_ru_verbose()) {
  # Find Geopoint columns
  gp_cols <- form_schema %>%
    dplyr::filter(type == "geopoint") %>%
    magrittr::extract2("ruodk_name") %>%
    intersect(names(data))

  if (verbose == TRUE) {
    x <- paste(gp_cols, collapse = ", ")
    ru_msg_info(glue::glue("Found geopoints: {x}."))
  }

  # Run split_geopoint on each geopoint column
  for (colname in gp_cols) {
    if (colname %in% names(data)) {
      if (verbose == TRUE) ru_msg_info(glue::glue("Parsing {colname}..."))
      data <- data %>% split_geopoint(as.character(colname))
    }
  }
  data
}

# usethis::use_test("handle_ru_geopoints")
