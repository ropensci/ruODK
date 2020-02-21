test_that("handle_ru_geopoints produces coordinates", {
  library(magrittr)
  data("fq_raw")
  data("fq_form_schema")

  fq_with_geo <- fq_raw %>%
    ruODK::odata_submission_rectangle() %>%
    ruODK::handle_ru_geopoints(form_schema = fq_form_schema)

  geopoint_fields <- fq_form_schema %>%
    dplyr::filter(type == "geopoint") %>%
    magrittr::extract2("ruodk_name")

  if (length(geopoint_fields) == 0) {
    rlang::warn(
      glue::glue(
        "test-handle_ru_geopoints needs test data",
        "with at least one geopoint field. Form schema:\n\n",
        "{knitr::kable(fq_form_schema)}"
      )
    )
  }

  # Geopoint fields have been split into separate coordinate components
  testthat::expect_false(geopoint_fields[[1]] %in% names(fq_with_geo))
})

# usethis::use_r("handle_ru_geopoints")
