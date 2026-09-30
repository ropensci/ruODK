test_that("form_schema_ext v8 returns a tibble with defaults", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
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
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
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
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
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
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
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
  question_with_choice_list <- fsx %>%
    subset(
      name == "choice_filter_question_2"
    )
  testthat::expect_true(tibble::is_tibble(fsx))
  testthat::expect_true("label" %in% names(fsx))
  testthat::expect_true("choices" %in% names(fsx))
  testthat::expect_false(is.na(question_with_choice_list$choices))
})

test_that("form_schema_ext v8 with label, choices, lang, and choice filter", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
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
  question_with_choice_list <- fsx %>%
    subset(
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

test_that("form_schema_ext v8 parses hints", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
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
  testthat::expect_true("hint" %in% names(fsx))
  testthat::expect_true("hint_english" %in% names(fsx))

  corner2 <- fsx |> subset(path == "/perimeter/corner2")
  testthat::expect_true(!is.na(corner2$hint_english))
  testthat::expect_true(nzchar(corner2$hint_english))
})

test_that("form_schema_ext v8 parses translated hints", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
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
  testthat::expect_true(tibble::is_tibble(fsx))
  testthat::expect_true("hint_english_(en)" %in% names(fsx))
  testthat::expect_true("hint_french_(fr)" %in% names(fsx))

  filtered <- fsx |> subset(path == "/select_example_filter")
  testthat::expect_equal(
    filtered$`hint_english_(en)`,
    "\"maybe\" is filtered out"
  )
  testthat::expect_equal(
    filtered$`hint_french_(fr)`,
    "\"maybe\" is filtered out"
  )
})

test_that("form_schema_ext reads a published version (#129)", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  s <- setup_moved_field_form(submit = FALSE)

  fsx_v1 <- form_schema_ext(
    pid = get_test_pid(),
    fid = s$fid,
    version = "grp1",
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  testthat::expect_true(tibble::is_tibble(fsx_v1))
  testthat::expect_true("/mygroup/myfield" %in% fsx_v1$path)

  fsx_latest <- form_schema_ext(
    pid = get_test_pid(),
    fid = s$fid,
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )
  testthat::expect_true("/myfield" %in% fsx_latest$path)
  testthat::expect_false("/mygroup/myfield" %in% fsx_latest$path)

  testthat::expect_error(
    form_schema_ext(
      pid = get_test_pid(),
      fid = s$fid,
      version = "",
      url = get_test_url(),
      un = get_test_un(),
      pw = get_test_pw()
    ),
    "single non-empty"
  )
})

blank_itemset_xml_139 <- function() {
  paste0(
    "<h:html xmlns=\"http://www.w3.org/2002/xforms\" ",
    "xmlns:h=\"http://www.w3.org/1999/xhtml\" ",
    "xmlns:jr=\"http://openrosa.org/javarosa\">",
    "<h:head><model><instance><data id=\"blank\"><q/></data></instance>",
    "<instance id=\"yes_no\"><root>",
    "<item><itextId>yes_no-0</itextId><name>0</name></item>",
    "<item><name>1</name></item>",
    "</root></instance>",
    "<itext>",
    "<translation lang=\"English\">",
    "<text id=\"yes_no-0\"><value>Yes</value></text>",
    "</translation>",
    "<translation lang=\"French\">",
    "<text id=\"yes_no-0\"><value>Oui</value></text>",
    "</translation>",
    "</itext></model></h:head>",
    "<h:body><select1 ref=\"/data/q\"><label>Q</label>",
    "<itemset nodeset=\"instance('yes_no')/root/item\">",
    "<value ref=\"name\"/><label ref=\"jr:itext(itextId)\"/>",
    "</itemset></select1></h:body></h:html>"
  )
}

blank_inline_xml_139 <- function() {
  paste0(
    "<h:html xmlns=\"http://www.w3.org/2002/xforms\" ",
    "xmlns:h=\"http://www.w3.org/1999/xhtml\" ",
    "xmlns:jr=\"http://openrosa.org/javarosa\">",
    "<h:head><model><instance><data id=\"blank\"><q/></data></instance>",
    "<itext>",
    "<translation lang=\"English\">",
    "<text id=\"q-opt0\"><value>Yes</value></text>",
    "</translation>",
    "<translation lang=\"French\">",
    "<text id=\"q-opt0\"><value>Oui</value></text>",
    "</translation>",
    "</itext></model></h:head>",
    "<h:body><select1 ref=\"/data/q\"><label>Q</label>",
    "<item><label ref=\"jr:itext('q-opt0')\"/><value>0</value></item>",
    "<item><label ref=\"jr:itext('q-opt1')\"/><value>1</value></item>",
    "</select1></h:body></h:html>"
  )
}

fake_schema_139 <- function() {
  tibble::tibble(
    path = "/q",
    name = "q",
    type = "string",
    binary = NA,
    ruodk_name = "q"
  )
}

test_that("form_schema_ext tolerates blank itemset choice labels (#139)", {
  testthat::local_mocked_bindings(
    form_schema = function(...) fake_schema_139(),
    form_xml = function(...) xml2::read_xml(blank_itemset_xml_139())
  )
  fsx <- testthat::expect_no_error(
    form_schema_ext(
      pid = 1,
      fid = "blank",
      url = "http://example.com",
      un = "u",
      pw = "p",
      odkc_version = "2023.1.0"
    )
  )
  testthat::expect_s3_class(fsx, "tbl_df")
  testthat::expect_equal(nrow(fsx), 1)
  testthat::expect_equal(fsx$choices_english[[1]]$values, c("0", "1"))
  testthat::expect_equal(fsx$choices_english[[1]]$labels, c("Yes", NA))
  testthat::expect_equal(fsx$choices_french[[1]]$values, c("0", "1"))
  testthat::expect_equal(fsx$choices_french[[1]]$labels, c("Oui", NA))
})

test_that("form_schema_ext tolerates blank inline choice labels (#139)", {
  testthat::local_mocked_bindings(
    form_schema = function(...) fake_schema_139(),
    form_xml = function(...) xml2::read_xml(blank_inline_xml_139())
  )
  fsx <- testthat::expect_no_error(
    form_schema_ext(
      pid = 1,
      fid = "blank",
      url = "http://example.com",
      un = "u",
      pw = "p",
      odkc_version = "2023.1.0"
    )
  )
  testthat::expect_s3_class(fsx, "tbl_df")
  testthat::expect_equal(nrow(fsx), 1)
  testthat::expect_equal(fsx$choices_english[[1]]$values, c("0", "1"))
  testthat::expect_equal(fsx$choices_english[[1]]$labels, c("Yes", NA))
})

test_that("lookup_translations tolerates missing ids (#139)", {
  doc <- xml2::read_xml(
    paste0(
      "<root><text id=\"a\"><value>hi</value></text>",
      "<text><value>noid</value></text></root>"
    )
  )
  t <- xml2::xml_find_all(doc, "//text")
  ids <- xml2::xml_attr(t, "id")
  testthat::expect_equal(length(lookup_translations(t, ids, NA)), 0)
  testthat::expect_equal(length(lookup_translations(t, ids, "missing")), 0)
  testthat::expect_equal(length(lookup_translations(t, ids, "a")), 1)
})

test_that("align_choice_labels pads blank labels with NA (#139)", {
  testthat::expect_equal(
    align_choice_labels(list("0", "1"), list(base = "Yes"))$base,
    c("Yes", NA)
  )
  testthat::expect_equal(
    align_choice_labels(list("0", "1"), list())$base,
    c(NA_character_, NA_character_)
  )
})

# usethis::use_r("form_schema_ext") # nolint
