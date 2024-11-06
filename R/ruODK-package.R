#' @description \code{\link{ruODK}} is an R Client for the ODK Central API.
#'
#'   Please see the `ruODK` website for full documentation:
#'   <https://docs.ropensci.org/ruODK/>
#'
#' `ruODK` is "pipe-friendly" and re-exports `\%>\%` and `\%||\%`, but does not
#'  require their use.
#'
#' @keywords internal
"_PACKAGE"

utils::globalVariables(c(
  ".",
  "archived",
  "children",
  "id",
  "name",
  "path",
  "type",
  "variable",
  "xx",
  "xml_form_id"
))

## usethis namespace: start
#' @import rlang
#' @importFrom glue glue
#' @importFrom lifecycle deprecated
## usethis namespace: end
NULL
