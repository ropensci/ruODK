#' A functional to extract names of list columns from a tibble.
#'
#' @param tbl A tibble, possibly with list columns
#' @return A vector of list column names
#' @importFrom dplyr summarise_all filter
#' @importFrom tidyr gather
#' @importFrom magrittr extract2
listcol_names <- function(tbl) {
  variable <- NULL
  tbl %>%
    dplyr::summarise_all(class) %>%
    tidyr::gather(variable, class) %>%
    dplyr::filter(class == "list") %>%
    magrittr::extract2("variable")
}

#' Recursively unnest_wide all list columns in a tibble.
#'
#' @param nested_tbl A nested tibble
#' @param names_repair The argument `names_repair` for `tibble::unnest_wider`,
#'   default: "universal".
#' @param verbose Whether to print verbose messages, default: FALSE.
#' @return The unnested tibble in wide format
#' @importFrom glue glue
#' @importFrom tidyr unnest_wider
#' @export
unnest_all <- function(nested_tbl,
                       names_repair = "universal",
                       verbose = FALSE) {
  for (colname in listcol_names(nested_tbl)) {
    # colname <- listcol_names(nested_tbl)[[1]]
    if (!(colname %in% names(nested_tbl))) {
      if (verbose == TRUE) {
        message(glue::glue("Skipping renamed column '{colname}'\n"))
      }
    } else {
      if (verbose == TRUE) {
        message(glue::glue("Unnesting column '{colname}'\n"))
      }
      nested_tbl <- tidyr::unnest_wider(
        nested_tbl, colname,
        names_repair = names_repair
      )
    }
  }
  if (length(listcol_names(nested_tbl)) > 0) {
    if (verbose == TRUE) {
      message("Found more nested columns, unnesting again.\n")
    }
    nested_tbl <- unnest_all(
      nested_tbl,
      names_repair = names_repair, verbose = verbose
    )
  }
  nested_tbl
}

#' Parse submissions into a tidy tibble and unnest all levels.
#'
#' @param data A nested list of lists as given by `ruODK::get_submissions`.
#' @param names_repair The argument `names_repair` for `tibble::unnest_wider`,
#'   default: "universal".
#' @param verbose Whether to print verbose messages, default: FALSE.
#' @return The submissions as unnested tibble
#' @importFrom tibble as_tibble
#' @export
parse_submissions <- function(data,
                              names_repair = "universal",
                              verbose = FALSE) {
  . <- NULL
  data %>%
    tibble::as_tibble(.) %>%
    unnest_all(names_repair = names_repair, verbose = verbose)
}
