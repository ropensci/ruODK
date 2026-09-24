test_that("form_draft_attachment_link links and unlinks a Dataset", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  ts <- format(Sys.time(), "%Y%m%d%H%M%S")
  stem <- glue::glue("cities_{ts}") |> as.character()
  csv <- paste0(stem, ".csv")
  fid <- glue::glue("ruodk_dattl_{ts}") |> as.character()

  entitylist_create(name = stem)

  withr::defer(
    try(
      httr::DELETE(
        paste0(
          get_test_url(),
          "/v1/projects/",
          get_test_pid(),
          "/datasets/",
          stem
        ),
        httr::authenticate(get_test_un(), get_test_pw())
      ),
      silent = TRUE
    )
  )

  form_create(xml = ru_test_form_xml(fid, itemset = csv), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  form_draft_create(fid = fid)

  linked <- form_draft_attachment_link(
    fid = fid,
    filename = csv,
    dataset = TRUE
  )
  testthat::expect_equal(linked$dataset_exists, TRUE)

  unlinked <- form_draft_attachment_link(
    fid = fid,
    filename = csv,
    dataset = FALSE
  )
  testthat::expect_equal(unlinked$dataset_exists, FALSE)

  form_draft_delete(fid = fid)
})

test_that("form_draft_attachment_link rejects invalid input", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    form_draft_attachment_link(
      fid = "f",
      filename = "",
      dataset = TRUE,
      url = url,
      un = un,
      pw = pw
    ),
    "single non-empty"
  )
  testthat::expect_error(
    form_draft_attachment_link(
      fid = "f",
      filename = "a.csv",
      dataset = "yes",
      url = url,
      un = un,
      pw = pw
    ),
    "TRUE or FALSE"
  )
})

# usethis::use_r("form_draft_attachment_link")  # nolint
