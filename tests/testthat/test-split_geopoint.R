test_that("split_geopoint works with integer coordinates", {
  df <- tibble::tibble(
    stuff = c("asd", "sdf", "sdf"),
    loc = c(
      "POINT (115 -32 20)",
      "POINT (116 -33 15)",
      "POINT (114 -31 23)"
    )
  )
  df_split <- df %>% split_geopoint("loc", wkt = TRUE)
  testthat::expect_equal(
    names(df_split),
    c("stuff", "loc", "loc_longitude", "loc_latitude", "loc_altitude")
  )
  testthat::expect_true(is.numeric(df_split$loc_latitude))
  testthat::expect_true(is.numeric(df_split$loc_longitude))
  testthat::expect_true(is.numeric(df_split$loc_altitude))
})


test_that("split_geopoint works with numeric coordinates", {
  df <- tibble::tibble(
    stuff = c("asd", "sdf", "sdf"),
    loc = c(
      "POINT (115.99 -32.12 20.01)",
      "POINT (116.12 -33.34 15.23)",
      "POINT (114.00 -31.56 23.56)"
    )
  )
  df_split <- df %>% split_geopoint("loc", wkt = TRUE)
  testthat::expect_equal(
    names(df_split),
    c("stuff", "loc", "loc_longitude", "loc_latitude", "loc_altitude")
  )

  testthat::expect_true(is.numeric(df_split$loc_latitude))
  testthat::expect_true(is.numeric(df_split$loc_longitude))
  testthat::expect_true(is.numeric(df_split$loc_altitude))
})






# Code
# usethis::edit_file("R/split_geopoint.R")
