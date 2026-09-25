#' Print an info message.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param message (chr) A message to print
#' @template param-verbose
#' @details Set `options(ruODK.quiet = TRUE)` to silence this message
#'   regardless of `verbose`.
#' @return NULL
#' @export
#' @family messaging
#' @examples
#' ru_msg_info("This is an info message.")
ru_msg_info <- function(message, verbose = get_ru_verbose()) {
  if (isTRUE(getOption("ruODK.quiet", default = FALSE))) {
    return(NULL)
  }
  if (verbose == FALSE) {
    return(NULL)
  }
  usethis::ui_info(message)
}

#' Print a success message.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param message (chr) A message to print
#' @template param-verbose
#' @details Set `options(ruODK.quiet = TRUE)` to silence this message
#'   regardless of `verbose`.
#' @return NULL
#' @export
#' @family messaging
#' @examples
#' ru_msg_success("This is a success message.")
ru_msg_success <- function(message, verbose = get_ru_verbose()) {
  if (isTRUE(getOption("ruODK.quiet", default = FALSE))) {
    return(NULL)
  }
  if (verbose == FALSE) {
    return(NULL)
  }
  usethis::ui_done(message)
}


#' Print a noop message.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param message (chr) A message to print
#' @template param-verbose
#' @details Set `options(ruODK.quiet = TRUE)` to silence this message
#'   regardless of `verbose`.
#' @return NULL
#' @export
#' @family messaging
#' @examples
#' ru_msg_noop("This is a noop message.")
ru_msg_noop <- function(message, verbose = get_ru_verbose()) {
  if (isTRUE(getOption("ruODK.quiet", default = FALSE))) {
    return(NULL)
  }
  if (verbose == FALSE) {
    return(NULL)
  }
  usethis::ui_todo(message)
}


#' Signal a warning message.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param message (chr) A message to print
#' @template param-verbose
#' @details Warnings are never silenced by `options(ruODK.quiet = TRUE)`.
#' @return NULL
#' @export
#' @family messaging
#' @examples
#' \dontrun{
#' ru_msg_warn("This is a warning.")
#' }
ru_msg_warn <- function(message, verbose = get_ru_verbose()) {
  if (verbose == FALSE) {
    return(NULL)
  }
  usethis::ui_warn(message)
}


#' Abort with an error message.
#'
#' `r lifecycle::badge("stable")`
#'
#' Errors are never silenced, neither by `verbose` nor by
#' `options(ruODK.quiet = TRUE)`.
#'
#' @param message (chr) A message to print
#' @return NULL
#' @export
#' @family messaging
#' @examples
#' \dontrun{
#' ru_msg_abort("This is an error, abort.")
#' }
ru_msg_abort <- function(message) {
  usethis::ui_stop(message)
}

# usethis::use_test("ru_msg") # nolint
