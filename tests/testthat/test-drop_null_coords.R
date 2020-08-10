test_that("drop_null_coords works on data with empty last coords ", {
  # This test will break once the ODK Central Sandbox has fixed
  # issue https://github.com/getodk/central-backend/issues/282
  # through https://github.com/getodk/central-backend/pull/283
  # and ruODK's package data have been updated.
  # We therefore have included a snapshot of test data exhibiting the problem.
  # The data uses "bad" coordinates from the ODK Sandbox and an unpatched ruODK.
  # The data "geo_gj" uses "bad" coordinates (soon: good coordinates) from the
  # ODK Sandbox and a patched ruODK.
  data("geo_gj88")

  len_coords <- length(geo_gj88$path_location_path_gps[[1]]$coordinates)

  length(geo_gj88$path_location_path_gps[[1]]$coordinates[[len_coords]]) %>%
    testthat::expect_equal(2)

  geo_gj88$path_location_path_gps[[1]]$coordinates[[len_coords]][[1]] %>%
    testthat::expect_null()

  geo_gj88$path_location_path_gps[[1]]$coordinates[[len_coords]][[2]] %>%
    testthat::expect_null()

  geo_gj_repaired <- geo_gj88 %>%
    dplyr::mutate(
      path_location_path_gps = path_location_path_gps %>%
        purrr::map(drop_null_coords)
    )

  len_coords_repaired <- length(
    geo_gj_repaired$path_location_path_gps[[1]]$coordinates
  )
  testthat::expect_equal(len_coords_repaired + 1, len_coords)
})

test_that("drop_null_coords works on data without empty last coords ", {
  data("geo_gj")

  len_coords <- length(geo_gj$path_location_path_gps[[1]]$coordinates)

  geo_gj_repaired <- geo_gj %>%
    dplyr::mutate(
      path_location_path_gps = path_location_path_gps %>%
        purrr::map(drop_null_coords)
    )

  len_coords_repaired <- length(
    geo_gj_repaired$path_location_path_gps[[1]]$coordinates
  )

  # No coordinates were harmed in the making of this test
  testthat::expect_equal(len_coords_repaired, len_coords)
})


# usethis::use_r("drop_null_coords")  # nolint
