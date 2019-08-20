#' #' Check whether we have internet
#' #'
#' #' @importFrom httr GET
#' has_internet <- function() {
#'   online <- !is.null(httr::GET("google.com"))
#'   if (online == FALSE) rlang::warn("Please check internet connectivity!")
#'   invisible(online)
#' }
