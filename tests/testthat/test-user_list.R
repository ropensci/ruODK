test_that("user_list returns list of users", {
  vcr::use_cassette("test_user_list0", {
  ul <- user_list()
  testthat::expect_s3_class(ul, "tbl_df")

  # names(ul)
  cn <- c("id",
          "type",
          "display_name",
          "created_at",
          "email",
          "updated_at")

  purrr::map(cn,
             ~ testthat::expect_true(
               . %in% names(ul),
               label = glue::glue("Column {.} missing from user_list")
             ))
  })
})

test_that("user_list returns filtered list of users", {
  vcr::use_cassette("test_user_list1", {

  # Use the first user's name to generate search strings
  ul <- user_list()
  ss3 <- substr(ul$display_name[[1]], 1, 3) # too short
  ss5 <- substr(ul$display_name[[1]], 1, 5) # long enough

  # Concerningly short search strings will emit a warning only if verbose
  testthat::expect_message(   # reason: provided query string
    testthat::expect_warning( # reason: query string too short
      ul_flt3 <- user_list(qry = ss3, verbose = TRUE)
    )
  )

  # No warning here
  ul_flt3 <- user_list(qry = ss3, verbose = FALSE)
  ul_flt5 <- user_list(qry = ss5)

  testthat::expect_gte(
    nrow(ul_flt3),
    0,
    label = "Short search strings (3 char) should return no matches"
  )

  testthat::expect_gte(
    nrow(ul_flt5),
    1,
    label = "Sufficiently long search strings (5 char) should return matches"
  )

  })
})