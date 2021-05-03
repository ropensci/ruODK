#' Print a blue info message with an info symbol.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param message (chr) A message to print
#' @template param-verbose
#' @return NULL
#' @export
#' @family utilities
#' @examples
#' ru_msg_info("This is an info message.")
ru_msg_info <- function(message, verbose = get_ru_verbose()) {
  if (verbose == FALSE) return(NULL)
  x <- clisymbols::symbol$info # nolint
  message(crayon::cyan(glue::glue("{x} {message}\n")))
}

#' Print a green success message with a tick symbol.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param message (chr) A message to print
#' @template param-verbose
#' @return NULL
#' @export
#' @family utilities
#' @examples
#' ru_msg_success("This is a success message.")
ru_msg_success <- function(message, verbose = get_ru_verbose()) {
  if (verbose == FALSE) return(NULL)
  x <- clisymbols::symbol$tick # nolint
  message(crayon::green(glue::glue("{x} {message}\n")))
}


#' Print a green noop message with a filled circle symbol.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param message (chr) A message to print
#' @template param-verbose
#' @return NULL
#' @export
#' @family utilities
#' @examples
#' ru_msg_noop("This is a noop message.")
ru_msg_noop <- function(message, verbose = get_ru_verbose()) {
  if (verbose == FALSE) return(NULL)
  x <- clisymbols::symbol$circle_filled # nolint
  message(crayon::green(glue::glue("{x} {message}\n")))
}


#' rlang::warn() with a yellow warning message with a warning symbol.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param message (chr) A message to print
#' @template param-verbose
#' @return NULL
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' ru_msg_warn("This is a warning.")
#' }
ru_msg_warn <- function(message, verbose = get_ru_verbose()) {
  if (verbose == FALSE) return(NULL)
  x <- clisymbols::symbol$warning # nolint
  rlang::warn(crayon::yellow(glue::glue("{x} {message}\n")))
}


#' rlang::abort() with a red error message with a cross symbol.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param message (chr) A message to print
#' @return NULL
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' ru_msg_abort("This is an error, abort.")
#' }
ru_msg_abort <- function(message) {
  x <- clisymbols::symbol$cross # nolint
  rlang::abort(crayon::red(glue::glue("{x} {message}\n")))
}
