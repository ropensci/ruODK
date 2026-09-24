local_itemset_form_xml <- function(fid) {
  paste0(
    '<h:html xmlns="http://www.w3.org/2002/xforms" ',
    'xmlns:h="http://www.w3.org/1999/xhtml" ',
    'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ',
    'xmlns:jr="http://openrosa.org/javarosa">',
    "<h:head><h:title>ruODK test</h:title><model><instance>",
    glue::glue('<data id="{fid}" version="1">'),
    "<meta><instanceID/></meta><city/></data>",
    "</instance>",
    '<instance id="cities" src="jr://file/cities.csv">',
    "<root><item><name/><label/></item></root></instance>",
    '<bind nodeset="/data/meta/instanceID" type="string" readonly="true()" ',
    'calculate="concat(\'uuid:\', uuid())"/>',
    '<bind nodeset="/data/city" type="string"/>',
    "</model></h:head>",
    "<h:body>",
    '<select1 ref="/data/city"><label>City</label>',
    '<itemset nodeset="instance(\'cities\')/root/item">',
    '<value ref="name"/><label ref="label"/></itemset></select1>',
    "</h:body></h:html>"
  )
}

test_that("form_attachment_list lists expected files", {
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
    "ruodk_fatt_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = local_itemset_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  al <- form_attachment_list(fid = fid)
  testthat::expect_equal(class(al), c("tbl_df", "tbl", "data.frame"))
  testthat::expect_true("cities.csv" %in% al$name)
  testthat::expect_false(al$exists[al$name == "cities.csv"])
})

test_that("form_attachment_list rejects missing input", {
  testthat::expect_error(
    form_attachment_list(fid = "f", url = "", un = "user", pw = "password"),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_attachment_list")  # nolint
