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
#' @details This function wraps a \code{dplyr::mutate_at} operation on all
#' datetime columns containing a tell-tale `col_contains` string like "time"
#' (default), "datetime" or "date". The operator using this function will have
#' to know the column names (or commonalities like `"..._time"`).
#' @param df A dataframe or tibble.
#' @param col_contains A character string indicating a date/time column.
#'   This can be a part of the column name or the whole column name.
#'   Default: "time" will match all column names containing "time".
#' @param orders (vector of character) Orders of datetime elements for
#'   lubridate.
#'   Default:
#'   \code{c("YmdHMS", "YmdHMSz", "Ymd HMS", "Ymd HMSz", "Ymd", "ymd")}.
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
#'   ru_datetime(dt_contains = "Date", tz = "Australia/Perth") %>%
#'   ru_datetime(tz = "Australia/Perth")
#' }
ru_datetime <- function(df,
                        col_contains = "time",
                        orders = c(
                          "YmdHMS",
                          "YmdHMSz",
                          "Ymd HMS",
                          "Ymd HMSz",
                          "Ymd",
                          "ymd"
                        ),
                        tz = "UTC") {
  df %>%
    dplyr::mutate_at(
      dplyr::vars(tidyr::contains(col_contains)),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

#' Split a column of a dataframe containing WKT POINT into lat, lon, alt.
#'
#' @param data (dataframe) A dataframe with a column of type WKT POINT
#' @param colname (chr) The name of the WKT POINT column
#' @return The given dataframe with the WKT POINT column <cn> replaced by three
#'   columns, `<colname>_latitude`, `<colname>_longitude`, `<colname>_altitude`.
#'   The three new columns are prefixed with the original `colname` to avoid
#'   naming conflicts with possible other geopoint columns.
#' @export
#' @family utilities
#' @examples
#' df <- tibble::tibble(
#'   stuff = c("asd", "sdf", "sdf"),
#'   loc = c(
#'     "POINT (-32 115 20)",
#'     "POINT (-33 116 15)",
#'     "POINT (-31 114 23)"
#'   )
#' )
#' df_split <- df %>% split_geopoint("loc")
#' names(df_split) == c(
#'   "stuff", "loc_latitude", "loc_longitude", "loc_altitude"
#' )
split_geopoint <- function(data, colname) {
  data %>%
    tidyr::extract(
      colname,
      c(
        glue::glue("{colname}_latitude"),
        glue::glue("{colname}_longitude"),
        glue::glue("{colname}_altitude")
      ),
      "POINT \\(([^,]+) ([^)]+) ([^,]+)\\)"
    )
}

# Tests
# usethis::use_test("split_geopoint")
