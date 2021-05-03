#' @param odkc_version The ODK Central version as decimal number (major.minor).
#'   `ruODK` uses this parameter to adjust for breaking changes in ODK Central.
#'
#'   Default: \code{\link{get_default_odkc_version}} or 1.1 if unset.
#'
#'   Set default \code{get_default_odkc_version} through
#'   \code{ru_setup(odkc_version=1.1)}.
#'
#'   See \code{vignette("Setup", package = "ruODK")}.
