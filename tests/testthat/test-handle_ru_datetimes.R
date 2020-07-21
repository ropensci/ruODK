test_that("handle_ru_datetimes produces datetimes", {
  library(magrittr)
  data("fq_raw")
  data("fq_form_schema")

  fq_with_dates <- fq_raw %>%
    ruODK::odata_submission_rectangle() %>%
    ruODK::handle_ru_datetimes(form_schema = fq_form_schema)

  # nolint start
  # fq_with_dates %>% purrr::map(class)
  # nolint end

  date_time_fields <- fq_form_schema %>%
    dplyr::filter(type == "dateTime") %>%
    magrittr::extract2("ruodk_name")

  if (length(date_time_fields) == 0) {
    rlang::warn(
      glue::glue(
        "test-handle_ru_datetimes needs test data",
        "with at least one dateTime field. Form schema:\n\n",
        "{knitr::kable(fq_form_schema)}"
      )
    )
  }

  # Is this a date?
  # https://i.imgur.com/NKRMXW4.jpg
  testthat::expect_equal(
    fq_with_dates %>% magrittr::extract2(date_time_fields[[1]]) %>% class(),
    c("POSIXct", "POSIXt")
  )
})

# usethis::use_r("handle_ru_datetimess") # nolint
