#' A functional to extract names of list columns from a tibble.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param tbl A tibble, possibly with list columns
#' @keywords internal
#' @return A vector of list column names
listcol_names <- function(tbl) {
  tbl %>%
    dplyr::summarise_all(class) %>%
    tidyr::gather(variable, class) %>%
    dplyr::filter(class == "list") %>%
    magrittr::extract2("variable")
}

#' Recursively unnest_wide all list columns in a tibble.
#'
#' `r lifecycle::badge("stable")`
#'
#' @details \code{\link{odata_submission_rectangle}} uses this function
#' internally.
#' Interested users can use this function to break down \code{ruODK}'s automated
#' steps into smaller components.
#'
#' The quite verbose output of \code{tidyr::unnest_wider} is captured
#' and hidden from the user.
#'
#' @param nested_tbl A nested tibble
#' @param names_repair The argument \code{names_repair} for
#'   \code{tidyr::unnest_wider}, default: "universal".
#' @param names_sep The argument \code{names_sep} for
#'   \code{tidyr::unnest_wider}, default: "_".
#'   Un-nested variables inside a list column will be prefixed by the list
#'   column name, separated by \code{names_sep}. This avoids unsightly repaired
#'   names such as \code{latitude...1}. Set to \code{NULL} to disable prefixing.
#' @template param-fs
#' @template param-verbose
#' @return The un-nested tibble in wide format
#' @family utilities
#' @keywords internal
unnest_all <- function(nested_tbl,
                       names_repair = "universal",
                       names_sep = "_",
                       form_schema = NULL,
                       verbose = get_ru_verbose()) {
  if (!is.null(form_schema)) {
    geofield_names <- form_schema %>%
      dplyr::filter(type %in% c("geopoint", "geotrace", "geoshape")) %>%
      magrittr::extract2("ruodk_name")

    if (length(geofield_names) == 0) {
      keep_nested <- vector()
    } else {
      keep_nested <- paste("value_", geofield_names, sep = "")
      x <- paste(keep_nested, collapse = ", ") # nolint
      "Not unnesting geo fields: {x}" %>%
        glue::glue() %>%
        ru_msg_info(verbose = verbose)
    }
  } else {
    keep_nested <- vector()
  }

  cols_to_unnest <- setdiff(listcol_names(nested_tbl), keep_nested)
  x <- paste(cols_to_unnest, collapse = ", ")
  "Unnesting: {x}" %>%
    glue::glue() %>%
    ru_msg_info(verbose = verbose)

  for (colname in cols_to_unnest) {
    if (!(colname %in% names(nested_tbl))) {
      # nolint start
      # # Diagnostic message
      # "Skipping renamed column \"{colname}\"" %>% glue::glue %>% ru_msg_info()
      # nolint end
    } else {
      " Unnesting column \"{colname}\"\n" %>%
        glue::glue() %>%
        ru_msg_info(verbose = verbose)

      # If any list elements are unnamed and names_sep=NULL, set safe params
      if (
        is.null(names_sep) &&
        any(vapply(nested_tbl[[colname]], function(x) is.null(names(x)), logical(1)))) {
        names_sep <- "_"
      }


      suppressMessages(
        nested_tbl <- tidyr::unnest_wider(
          nested_tbl,
          dplyr::all_of(colname),
          names_repair = names_repair,
          names_sep = names_sep
        )
      )
    }
  }

  cols_to_unnest <- setdiff(listcol_names(nested_tbl), keep_nested)
  if (length(cols_to_unnest) > 0) {
    x <- paste(cols_to_unnest, collapse = ", ")
    "Unnesting more list cols: {x}" %>%
      glue::glue() %>%
      ru_msg_info(verbose = verbose)

    nested_tbl <- unnest_all(
      nested_tbl,
      names_repair = names_repair,
      names_sep = names_sep,
      form_schema = form_schema,
      verbose = verbose
    )
  }
  nested_tbl
}


#' Rectangle the output of \code{\link{odata_submission_get}(parse=FALSE)}
#' into a tidy tibble and unnest all levels.
#'
#' `r lifecycle::badge("stable")`
#'
#' This function cleans names with `janitor::clean_names()` and drops the
#' prefix `value_`.
#'
#' @param data A nested list of lists as given by
#'   \code{\link{odata_submission_get}}.
#' @param names_repair The argument \code{names_repair} for
#'   \code{tidyr::unnest_wider}, default: "universal".
#' @param names_sep The argument \code{names_sep} for
#'   \code{tidyr::unnest_wider}, default: "_".
#'   Un-nested variables inside a list column will be prefixed by the list
#'   column name, separated by \code{names_sep}.
#'   This avoids unsightly repaired names such as \code{latitude...1}.
#' @template param-fs
#' @param clean_names Whether to run `janitor::clean_names()`.
#'   Set `clean_names=FALSE` to preserve any non-standard `names_sep`.
#'   Default: TRUE.
#' @template param-verbose
#' @return The submissions as un-nested tibble
#' @family utilities
#' @export
#' @examples
#' \dontrun{
#' # Using canned data
#' data_parsed <- odata_submission_rectangle(fq_raw, verbose = TRUE)
#' # Field "device_id" is known part of fq_raw
#' testthat::expect_equal(
#'   data_parsed$device_id[[1]],
#'   fq_raw$value[[1]]$device_id
#' )
#'
#' # fq_raw has two submissions
#' testthat::expect_equal(length(fq_raw$value), nrow(data_parsed))
#' }
odata_submission_rectangle <- function(data,
                                       names_repair = "universal",
                                       names_sep = "_",
                                       form_schema = NULL,
                                       clean_names = TRUE,
                                       verbose = get_ru_verbose()) {
  data %>%
    {
      # nolint
      suppressMessages(tibble::as_tibble(data, .name_repair = names_repair))
    } %>%
    unnest_all(
      names_repair = names_repair,
      names_sep = names_sep,
      form_schema = form_schema,
      verbose = verbose
    ) %>%
    {
      if (clean_names == TRUE)
        janitor::clean_names(.)
      else
        .
    } %>%
    dplyr::rename_at(dplyr::vars(dplyr::starts_with("value_")),
                     ~ stringr::str_remove(., "value_"))
}

# usethis::use_test("odata_submission_rectangle") # nolint
