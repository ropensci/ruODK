#' Shim to allow Import of lifecycle, required for building docs.
#'
#' HT Jim Hester, Lionel Henry, Jenny Bryan for advice
#' @importFrom lifecycle deprecate_soft
#' @keywords internal
lifecycle_shim <- function() {
  lifecycle::deprecate_soft(when = "1.0", what = "lifecycle_shim()")
}

# usethis::use_test("utils-lifecycle") # nolint
