#' Parse an ISO8601 datetime string to a timezone aware datetime.
#'
#' `r lifecycle::badge("stable")`
#'
#' This function is used internally by `ruODK` to parse ISO timestamps
#' to timezone-aware local times.
#'
#' Warnings are suppressed through `lubridate::parse_date_time(quiet=TRUE)`.
#'
#' @param datetime_string (character) An ISO8601 datetime string as produced by
#'   XForms exported from ODK Central.
#' @param orders (vector of character) Orders of datetime elements for
#'   `lubridate`.
#'   Default: \code{c("YmdHMS", "YmdHMSz", "Ymd HMS", "Ymd HMSz")}.
#' @template param-tz
#' @param quiet (bool) Used in `lubridate::parse_date_time(quiet=quiet)` to
#'   suppress warnings from attempting to parse all empty values or columns.
#'   Run with `quiet=FALSE` to show any `lubridate` warnings.
#' @return A `lubridate` PosixCT datetime in the given timezone.
#' @family utilities
#' @keywords internal
isodt_to_local <- function(datetime_string,
                           orders = c("YmdHMS", "YmdHMSz"),
                           tz = get_default_tz(),
                           quiet=TRUE
                           ) {
  datetime_string %>%
    lubridate::parse_date_time(orders = orders, quiet=quiet) %>%
    lubridate::with_tz(., tzone = tz)
}
