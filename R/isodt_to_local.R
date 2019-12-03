#' Parse an ISO8601 datetime string to a timezone aware datetime.
#'
#' \lifecycle{stable}
#' @param datetime_string (character) An ISO8601 datetime string as produced by
#'   XForms exported from ODK Central.
#' @param orders (vector of character) Orders of datetime elements for
#'   lubridate.
#'   Default: \code{c("YmdHMS", "YmdHMSz", "Ymd HMS", "Ymd HMSz")}.
#' @param tz (character) The timezone string for lubridate.
#'   Default: \code{"UTC"}.
#' @return A lubridate PosixCT datetime in the given timezone.
#' @family utilities
#' @export
isodt_to_local <- function(datetime_string,
                           orders = c("YmdHMS", "YmdHMSz"),
                           tz = "UTC") {
  datetime_string %>%
    lubridate::parse_date_time(orders = orders) %>%
    lubridate::with_tz(., tzone = tz)
}
