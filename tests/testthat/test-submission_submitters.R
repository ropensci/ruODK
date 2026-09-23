local_uuid <- function() {
  hex <- function(n) {
    paste(sample(c(0:9, letters[1:6]), n, replace = TRUE), collapse = "")
  }
  paste0("uuid:", hex(8), "-", hex(4), "-4", hex(3), "-", hex(4), "-", hex(12))
}

test_that("submission_submitters lists submitting Actors once each", {
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

  fid <- glue::glue(
    "ruodk_subs_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(
    xml = paste0(
      '<h:html xmlns="http://www.w3.org/2002/xforms" ',
      'xmlns:h="http://www.w3.org/1999/xhtml">',
      "<h:head><h:title>ruODK test</h:title><model><instance>",
      glue::glue('<data id="{fid}"><meta><instanceID/></meta><name/></data>'),
      "</instance>",
      '<bind nodeset="/data/name" type="string"/>',
      "</model></h:head>",
      "<h:body>",
      '<input ref="/data/name"><label>What is your name?</label></input>',
      "</h:body></h:html>"
    ),
    publish = TRUE
  )

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  iid <- local_uuid()
  submission_create(
    fid = fid,
    xml = paste0(
      glue::glue('<data id="{fid}">'),
      glue::glue("<meta><instanceID>{iid}</instanceID></meta>"),
      "<name>Jo</name></data>"
    )
  )

  st <- submission_submitters(fid = fid)
  testthat::expect_equal(class(st), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true(all(c("id", "display_name", "type") %in% names(st)))
  testthat::expect_gte(nrow(st), 1)
})

test_that("submission_submitters returns no rows for a Form without Submissions", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  fid <- glue::glue(
    "ruodk_subse_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(
    xml = paste0(
      '<h:html xmlns="http://www.w3.org/2002/xforms" ',
      'xmlns:h="http://www.w3.org/1999/xhtml">',
      "<h:head><h:title>ruODK test</h:title><model><instance>",
      glue::glue('<data id="{fid}"><meta><instanceID/></meta><name/></data>'),
      "</instance>",
      '<bind nodeset="/data/name" type="string"/>',
      "</model></h:head>",
      "<h:body>",
      '<input ref="/data/name"><label>What is your name?</label></input>',
      "</h:body></h:html>"
    ),
    publish = TRUE
  )

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  st <- submission_submitters(fid = fid)
  testthat::expect_equal(nrow(st), 0)
})

test_that("submission_submitters rejects missing input", {
  testthat::expect_error(
    submission_submitters(
      fid = "f",
      url = "",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("submission_submitters")  # nolint
