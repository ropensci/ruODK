#' Shim to allow Import of lifecycle, required for building docs.
#'
#' HT Jim Hester, Lionel Henry, Jenny Bryan for advice
#' @importFrom lifecycle deprecate_soft
#' @keywords internal
lifecycle_shim <- function(){
  if (FALSE) lifecycle::deprecate_soft()
  return(NULL)
}

# usethis::use_test("utils-lifecycle")
