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

#' Parse all columns containing a certain word in its name to localised
#' datetime.
#'
#' \lifecycle{stable}
#' @details This function wraps a \code{`dplyr::mutate_at()`} operation on all
#' datetime columns containing a tell-tale `col_contains` string like "time"
#' (default), "datetime" or "date". The operator using this function will have
#' to know the column names (or commonalities like `"..._time"`).
#' @param df A dataframe or tibble.
#' @param col_contains A character string indicating a date/time column.
#'   This can be a part of the column name or the whole column name.
#'   Default: "time" will match all column names containing "time".
#' @param orders (vector of character) Orders of datetime elements for
#'   lubridate.
#'   Default: \code{c("YmdHMS", "YmdHMSz")}.
#' @param tz (character) The timezone string for lubridate.
#'   Default: \code{"UTC"}.
#' @return The dataframe with matching columns mutated to lubridate datetimes.
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' tsi <- "data/build_Turtle-Sighting-0-1_1559790020.csv" %>%
#'   readr::read_csv(na = c("", "NA", "na")) %>%
#'   janitor::clean_names() %>%
#'   link_attachments() %>%
#'   parse_datetime(dt_contains = "Date", tz = "Australia/Perth") %>%
#'   parse_datetime(tz = "Australia/Perth")
#' }
parse_datetime <- function(df,
                           col_contains = "time",
                           orders = c(
                             "YmdHMS", "YmdHMSz",
                             "Ymd HMS", "Ymd HMSz"
                           ),
                           tz = "Australia/Perth") {
  df %>%
    dplyr::mutate_at(
      dplyr::vars(tidyr::contains(col_contains)),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}
