#' Map given function, handle null as NA and flatten_chr()
#'
#' @details Use this function to extract chr elements with NAs from a list of lists
#' into a tibble.
#'
#' @param .x An interable data object
#' @param .f A function to map over the data
#' @param ... Extra arguments to `map()`
#' @author Jennifer Bryan https://github.com/jennybc/
#' @export
map_chr_hack <- function(.x, .f, ...) {
  purrr::map(.x, .f, ...) %>%
    purrr::map_if(is.null, ~NA_character_) %>%
    purrr::flatten_chr()
}


#' Map given function, handle null as NA, flatten_chr() and convert to dttm
#'
#' @details Use this function to extract ISO timestamps with NAs from a list of lists
#' into a tibble.
#'
#' @param .x An interable data object
#' @param .f A function to map over the data
#' @param ... Extra arguments to `map()`
#' @export
map_dttm_hack <- function(.x, .f, ...) {
  . <- NULL
  purrr::map(.x, .f, ...) %>%
    purrr::map_if(is.null, ~NA) %>%
    purrr::flatten_chr(.) %>%
    readr::parse_datetime(., format = "%Y-%m-%dT%H:%M:%OS%Z")
}
