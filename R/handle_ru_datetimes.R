#' Parse datetimes of submission data according to a form schema.
#'
#' \lifecycle{maturing}
#'
#' @details For a given tibble of submissions, parse all columns which are
#' marked in the form schema as type "date" or "dateTime" using a set of
#' lubridate orders and a given timezone.
#' @param data Submissions rectangled into a tibble. E.g. the output of
#'   ```
#'   ruODK::odata_submission_get(parse = FALSE) %>%
#'   ruODK::odata_submission_rectangle()
#'   ```
#' @param form_schema The `form_schema` for the submissions.
#'   E.g. the output of `ruODK::form_schema()`.
#' @template param-orders
#' @template param-tz
#' @template param-verbose
#' @return The submissions tibble with all date/dateTime columns mutated as
#'   lubridate datetimes.
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' library(magrittr)
#' data("fq_raw")
#' data("fq_form_schema")
#'
#' fq_with_dates <- fq_raw %>%
#'   ruODK::odata_submission_rectangle() %>%
#'   ruODK::handle_ru_datetimes(form_schema = fq_form_schema)
#'
#' dplyr::glimpse(fq_with_dates)
#' }
handle_ru_datetimes <- function(data,
                                form_schema,
                                orders = c(
                                  "YmdHMS",
                                  "YmdHMSz",
                                  "Ymd HMS",
                                  "Ymd HMSz",
                                  "Ymd",
                                  "ymd"
                                ),
                                tz = get_default_tz(),
                                verbose = get_ru_verbose()) {
  # Find all date/time columns in form_schema
  dttm_cols <- form_schema %>%
    dplyr::filter(type %in% c("dateTime", "date")) %>%
    magrittr::extract2("ruodk_name") %>%
    intersect(names(data))

  if (verbose == TRUE) {
    x <- paste(dttm_cols, collapse = ", ")
    ru_msg_info(glue::glue("Found date/times: {x}."))
  }

  data %>%
    dplyr::mutate_at(
      dplyr::vars(tidyselect::all_of(dttm_cols)),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("handle_ru_datetimes")
