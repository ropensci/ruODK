test_that("split_geopoint works", {
  df <- tibble::tibble(
    stuff = c("asd", "sdf", "sdf"),
    loc = c(
      "POINT (-32 115 20)",
      "POINT (-33 116 15)",
      "POINT (-31 114 23)"
    )
  )
  df_split <- df %>% split_geopoint("loc")
  testthat::expect_equal(
    names(df_split),
    c("stuff", "loc_latitude", "loc_longitude", "loc_altitude")
  )
})

# Code
# usethis::edit_file("R/utils.R")
