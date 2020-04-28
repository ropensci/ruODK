#' @param odkc_version The ODK Central version as decimal number (major.minor).
#'   `ruODK` uses this parameter to adjust for breaking changes in ODK Central.
#'   Default: \code{\link{get_default_odkc_version}} or 0.8 if unset.
#'   Set default \code{get_default_odkc_version} through
#'   \code{ru_setup(odkc_version=0.8)}.
#'   See \code{vignette("Setup", package = "ruODK")}.
