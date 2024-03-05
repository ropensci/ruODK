#' @param odkc_version The ODK Central version as a semantic version string
#'   (year.minor.patch), e.g. "2023.5.1". The version is shown on ODK Central's
#'   version page `/version.txt`. Discard the "v".
#'   `ruODK` uses this parameter to adjust for breaking changes in ODK Central.
#'
#'   Default: \code{\link{get_default_odkc_version}} or "2023.5.1" if unset.
#'
#'   Set default \code{get_default_odkc_version} through
#'   \code{ru_setup(odkc_version="2023.5.1")}.
#'
#'   See \code{vignette("Setup", package = "ruODK")}.
