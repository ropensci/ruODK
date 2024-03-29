test_that("form_schema_ext v8 returns a tibble with defaults", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  fsx <- form_schema_ext(
    pid = get_test_pid(),
    fid = get_test_fid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  testthat::expect_true(tibble::is_tibble(fsx))
  testthat::expect_true("label" %in% names(fsx))
  testthat::expect_true("choices" %in% names(fsx))
  testthat::expect_true("label_english" %in% names(fsx))
  testthat::expect_true("choices_english" %in% names(fsx))
})

# TODO fix this test
# test_that("form_schema_ext v8 in a form with no languages", {
#   skip_if(Sys.getenv("ODKC_TEST_URL") == "",
#     message = "Test server not configured"
#   )
#
#   fsx <- form_schema_ext(
#     pid = get_test_pid(),
#     fid = Sys.getenv(
#       "ODKC_TEST_FID_I8N0", unset = "I8n_no_lang_choicefilter"
#     ),
#     url = get_test_url(),
#     un = get_test_un(),
#     pw = get_test_pw(),
#     odkc_version = get_test_odkc_version()
#   )
#   # TODO error: form_schema_ext v8 in a form with no languages
#   testthat::expect_true(tibble::is_tibble(fsx))
#   testthat::expect_true("label" %in% names(fsx))
#   testthat::expect_true("choices" %in% names(fsx))
# })

test_that("form_schema_ext v8 in a form with label languages", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
  fsx <- form_schema_ext(
    pid = get_test_pid(),
    fid = Sys.getenv("ODKC_TEST_FID_I8N1", unset = "I8n_label_lng"),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  testthat::expect_true(tibble::is_tibble(fsx))
  testthat::expect_true("label_english_(en)" %in% names(fsx))
  testthat::expect_true("label_french_(fr)" %in% names(fsx))
})

test_that("form_schema_ext v8 in a form with label and choices languages", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  fsx <- form_schema_ext(
    pid = get_test_pid(),
    fid = Sys.getenv("ODKC_TEST_FID_I8N2", unset = "I8n_label_choices"),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  testthat::expect_true(tibble::is_tibble(fsx))
  testthat::expect_true("label" %in% names(fsx))
  testthat::expect_true("choices" %in% names(fsx))
  testthat::expect_true("label_english_(en)" %in% names(fsx))
  testthat::expect_true("label_french_(fr)" %in% names(fsx))
  testthat::expect_true("choices_english_(en)" %in% names(fsx))
  testthat::expect_true("choices_french_(fr)" %in% names(fsx))
})

test_that("form_schema_ext v8 in a form with no languages and choice filter", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  fsx <- form_schema_ext(
    pid = get_test_pid(),
    fid = Sys.getenv(
      "ODKC_TEST_FID_I8N3",
      unset = "I8n_no_lang_choicefilter"
    ),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  question_with_choice_list <- fsx %>% subset(
    name == "choice_filter_question_2"
  )
  testthat::expect_true(tibble::is_tibble(fsx))
  testthat::expect_true("label" %in% names(fsx))
  testthat::expect_true("choices" %in% names(fsx))
  testthat::expect_false(is.na(question_with_choice_list$choices))
})

test_that("form_schema_ext v8 with label, choices, lang, and choice filter", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  fsx <- form_schema_ext(
    pid = get_test_pid(),
    fid = Sys.getenv("ODKC_TEST_FID_I8N4", unset = "I8n_lang_choicefilter"),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  question_with_choice_list <- fsx %>% subset(
    name == "choice_filter_question_2"
  )
  testthat::expect_true(tibble::is_tibble(fsx))
  testthat::expect_true("label" %in% names(fsx))
  testthat::expect_true("choices" %in% names(fsx))
  testthat::expect_true("label_english_(en)" %in% names(fsx))
  testthat::expect_true("label_french_(fr)" %in% names(fsx))
  testthat::expect_true("choices_english_(en)" %in% names(fsx))
  testthat::expect_true("choices_french_(fr)" %in% names(fsx))
  testthat::expect_false(is.na(
    question_with_choice_list$`choices_english_(en)`
  ))
})


# usethis::use_r("form_schema_ext") # nolint
