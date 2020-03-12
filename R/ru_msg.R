#' Print a blue info message with an info symbol.
#'
#' \lifecycle{stable}
#'
#' @param message <chr> A message to print
#' @return NULL
#' @export
#' @family helpers
#' @examples
#' ru_msg_info("This is an info message.")
ru_msg_info <- function(message) {
  x <- clisymbols::symbol$info
  message(crayon::cyan(glue::glue("{x} {message}\n")))
}

#' Print a green success message with a tick symbol.
#'
#' \lifecycle{stable}
#'
#' @param message <chr> A message to print
#' @return NULL
#' @export
#' @family helpers
#' @examples
#' ru_msg_success("This is a success message.")
ru_msg_success <- function(message) {
  x <- clisymbols::symbol$tick
  message(crayon::green(glue::glue("{x} {message}\n")))
}


#' Print a green noop message with a filled circle symbol.
#'
#' \lifecycle{stable}
#'
#' @param message <chr> A message to print
#' @return NULL
#' @export
#' @family helpers
#' @examples
#' ru_msg_noop("This is a noop message.")
ru_msg_noop <- function(message) {
  x <- clisymbols::symbol$circle_filled
  message(crayon::green(glue::glue("{x} {message}\n")))
}


#' rlang::warn() with a yellow warning message with a warning symbol.
#'
#' \lifecycle{stable}
#'
#' @param message <chr> A message to print
#' @return NULL
#' @export
#' @family helpers
#' @examples
#' \dontrun{
#' ru_msg_warn("This is a warning.")
#' }
ru_msg_warn <- function(message) {
  x <- clisymbols::symbol$warning
  rlang::warn(crayon::yellow(glue::glue("{x} {message}\n")))
}


#' rlang::abort() with a red error message with a cross symbol.
#'
#' \lifecycle{stable}
#'
#' @param message <chr> A message to print
#' @return NULL
#' @export
#' @family helpers
#' @examples
#' \dontrun{
#' ru_msg_abort("This is an error, abort.")
#' }
ru_msg_abort <- function(message) {
  x <- clisymbols::symbol$cross
  rlang::abort(crayon::red(glue::glue("{x} {message}\n")))
}