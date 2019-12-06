#' A functional to extract names of list columns from a tibble.
#'
#' \lifecycle{stable}
#'
#' @param tbl A tibble, possibly with list columns
#' @keywords internal
#' @return A vector of list column names
listcol_names <- function(tbl) {
  variable <- NULL
  tbl %>%
    dplyr::summarise_all(class) %>%
    tidyr::gather(variable, class) %>%
    dplyr::filter(class == "list") %>%
    magrittr::extract2("variable")
}

#' Predict the column type based on optional form_schema
#' This is stupid, we should map first, then parse
# predict_ptype <- function(cn, fs=NULL){
#  return("chr")
# }

#' Recursively unnest_wide all list columns in a tibble.
#'
#' \lifecycle{stable}
#'
#' @details \code{\link{odata_submission_parse}}uses this function internally.
#' Interested users can use this function to break down `ruODK`'s automated
#' steps into smaller components.
#'
#' The quite verbose output of \code{tidyr::unnest_wider} is captured
#' and hidden from the user.
#'
#' @param nested_tbl A nested tibble
#' @param names_repair The argument `names_repair` for
#'   \code{tidyr::unnest_wider}, default: "universal".
#' @param verbose Whether to print verbose messages, default: FALSE.
#' @return The unnested tibble in wide format
#' @family odata-api
#' @export
unnest_all <- function(nested_tbl,
                       names_repair = "universal",
                       verbose = FALSE) {
  for (colname in listcol_names(nested_tbl)) {
    # colname <- listcol_names(nested_tbl)[[1]]
    if (!(colname %in% names(nested_tbl))) {
      if (verbose == TRUE) {
        message(crayon::cyan(
          glue::glue("{clisymbols::symbol$info}",
                     "Skipping renamed column \"{colname}\"\n")
        ))
      }

    } else {
      if (verbose == TRUE) {
        message(crayon::cyan(
          glue::glue("{clisymbols::symbol$info}",
                     "Unnesting column \"{colname}\"\n")
        ))
      }

      # If colname contains NULL, we have to supply ptype
      # pt <- predict_ptype(colname, form_schema){}

      # If colname is of type geopoint (form_schema knows), split_geopoint

      # If colname is of type dateTime or date, ru_datetime

      suppressMessages( # ball-gag unnest_wider
        nested_tbl <- tidyr::unnest_wider(
          nested_tbl,
          colname,
          names_repair = names_repair
        )
      )
    }
  }
  if (length(listcol_names(nested_tbl)) > 0) {
    if (verbose == TRUE) {
      message(crayon::cyan(
        glue::glue("{clisymbols::symbol$info}",
                   "Found more nested columns, unnesting again.\n")
      ))
    }
    nested_tbl <- unnest_all(
      nested_tbl,
      names_repair = names_repair,
      verbose = verbose
    )
  }
  nested_tbl
}

#' Parse the output of \code{\link{odata_submission_get}(parse=FALSE)}
#' into a tidy tibble and unnest all levels.
#'
#' \lifecycle{maturing}
#'
#' Coming soon: [Better column names](https://github.com/dbca-wa/ruODK/issues/7)
#'
#' @param data A nested list of lists as given by
#'   \code{\link{odata_submission_get}}.
#' @param form_schema The output of \code{\link{form_schema}} for the given
#'   data. \code{\link{odata_submission_get}(parse=TRUE)} automatically supplies
#'   \code{form_schema} to \code{\link{odata_submission_parse}}.
#' @param names_repair The argument `names_repair` for
#'   \code{tidyr::unnest_wider}, default: "universal".
#' @param verbose Whether to print verbose messages, default: FALSE.
#' @return The submissions as unnested tibble
#' @family odata-api
#' @export
#' @examples
#' \dontrun{
#' # Using canned data
#' data_parsed <- parse_submissions(fq_raw, verbose = TRUE)
#' # Field "device_id" is known part of fq_raw
#' testthat::expect_equal(
#'   data_parsed$device_id[[1]],
#'   fq_raw$value[[1]]$device_id
#' )
#'
#' # fq_raw has two submissions
#' testthat::expect_equal(length(fq_raw$value), nrow(data_parsed))
#' }
odata_submission_parse <- function(data,
                                   form_schema = NULL,
                                   names_repair = "universal",
                                   verbose = FALSE) {

  # TODO
  # if (!is.null(form_schema)){
    # TODO parse with form_schema
    # } else {

      data %>%
        tibble::as_tibble(., .name_repair = names_repair) %>%
        unnest_all(names_repair = names_repair, verbose = verbose) %>%
        janitor::clean_names(.)
    # }
}


# Tests
# usethis::edit_file("tests/testthat/test-odata_submission_parse.R")
