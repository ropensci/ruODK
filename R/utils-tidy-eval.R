#' Tidy eval helpers
#'
#' These functions provide tidy eval-compatible ways to capture
#' symbols (`sym()`, `syms()`, `ensym()`), expressions (`expr()`,
#' `exprs()`, `enexpr()`), and quosures (`quo()`, `quos()`, `enquo()`).
#' To learn more about tidy eval and how to use these tools, read
#' <http://rlang.tidyverse.org/articles/tidy-evaluation.html>
#'
#' @name tidyeval
#' @keywords internal
#' @family utilities
#' @aliases          quo quos enquo sym syms ensym expr exprs enexpr quo_name
#' @importFrom rlang quo quos enquo sym syms ensym expr exprs enexpr quo_name
#' @importFrom tidyselect all_of any_of one_of contains ends_with starts_with everything
#' @importFrom rlang UQ UQS .data := %||%
#' @export  quo quos enquo sym syms ensym expr exprs enexpr quo_name
NULL
