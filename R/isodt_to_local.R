#' Parse an ISO8601 datetime string to a timezone aware datetime.
#'
#' \lifecycle{stable}
#'
#' This function is used internally by \code{ruODK} to parse ISO timestamps
#' to timezone-aware local times.
#'
#' @param datetime_string (character) An ISO8601 datetime string as produced by
#'   XForms exported from ODK Central.
#' @param orders (vector of character) Orders of datetime elements for
#'   lubridate.
#'   Default: \code{c("YmdHMS", "YmdHMSz", "Ymd HMS", "Ymd HMSz")}.
#' @template param-tz
#' @return A lubridate PosixCT datetime in the given timezone.
#' @family utilities
#' @keywords internal
isodt_to_local <- function(datetime_string,
                           orders = c("YmdHMS", "YmdHMSz"),
                           tz = get_default_tz()) {
  datetime_string %>%
    lubridate::parse_date_time(orders = orders) %>%
    lubridate::with_tz(., tzone = tz)
}
