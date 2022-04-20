test_that("user_list returns list of users", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  ul <- user_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  testthat::expect_s3_class(ul, "tbl_df")

  cn <- c(
    "id",
    "type",
    "display_name",
    "created_at",
    "email",
    "updated_at"
  )

  purrr::map(
    cn,
    ~ testthat::expect_true(
      . %in% names(ul),
      label = glue::glue("Column {.} missing from user_list")
    )
  )
})

test_that("user_list returns filtered list of users", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # Use the first user's name to generate search strings
  ul <- user_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )
  ss3 <- substr(ul$display_name[[1]], 1, 3) # too short
  ss5 <- substr(ul$display_name[[1]], 1, 5) # long enough

  # Concerningly short search strings will emit a warning only if verbose
  testthat::expect_message(
    # reason: provided query string
    testthat::expect_warning(
      # reason: query string too short
      ul_flt3 <- user_list(
        url = get_test_url(),
        un = get_test_un(),
        pw = get_test_pw(),
        qry = ss3,
        verbose = TRUE
      )
    )
  )

  # No warning here
  ul_flt3 <- user_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    qry = ss3,
    verbose = FALSE
  )
  ul_flt5 <- user_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    qry = ss5
  )

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

# usethis::use_r("user_list")  # nolint
