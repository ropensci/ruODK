test_that("ru_setup does not update settings if given NULL", {
  xx <- ru_settings()

  # This does not change settings
  ru_setup(
    svc = NULL,
    pid = NULL,
    fid = NULL,
    url = NULL,
    un = NULL,
    pw = NULL,
    tz = NULL,
    test_svc = NULL,
    test_pid = NULL,
    test_fid = NULL,
    test_fid_zip = NULL,
    test_fid_att = NULL,
    test_fid_gap = NULL,
    test_url = NULL,
    test_un = NULL,
    test_pw = NULL,
    verbose = NULL
  )

  # Get current (unchanged) settings
  x <- ru_settings()

  # Settings are still the default/test settings
  # If env vars not set, default getters will issue warnings
  testthat::expect_equal(x$url, get_default_url())
  testthat::expect_equal(xx$url, get_default_url())
  testthat::expect_equal(x$un, get_default_un())
  testthat::expect_equal(x$pw, get_default_pw())
  testthat::expect_equal(x$tz, get_default_tz())
  testthat::expect_equal(x$test_url, get_test_url())
  testthat::expect_equal(x$test_un, get_test_un())
  testthat::expect_equal(x$test_pw, get_test_pw())
  testthat::expect_equal(x$test_pid, get_test_pid())
  testthat::expect_equal(x$test_fid, get_test_fid())
  testthat::expect_equal(x$test_fid_zip, get_test_fid_zip())
  testthat::expect_equal(x$test_fid_att, get_test_fid_att())
  testthat::expect_equal(x$test_fid_gap, get_test_fid_gap())
  testthat::expect_equal(x$verbose, get_ru_verbose())
})

test_that("ru_setup resets settings if given empty string", {

  # Keep original test settings
  url <- get_default_url()
  un <- get_default_un()
  pw <- get_default_pw()
  tz <- get_default_tz()
  verbose <- get_ru_verbose()
  test_url <- get_test_url()
  test_un <- get_test_un()
  test_pw <- get_test_pw()
  test_pid <- get_test_pid()
  test_fid <- get_test_fid()
  test_fid_zip <- get_test_fid_zip()
  test_fid_att <- get_test_fid_att()
  test_fid_gap <- get_test_fid_gap()

  # Hammertime
  ru_setup(
    pid = "",
    fid = "",
    url = "",
    un = "",
    pw = "",
    tz = "",
    test_pid = "",
    test_fid = "",
    test_fid_zip = "",
    test_fid_att = "",
    test_fid_gap = "",
    test_url = "",
    test_un = "",
    test_pw = "",
    verbose = FALSE
  )
  x <- ru_settings()

  # Yell at me
  testthat::expect_warning(get_default_pid())
  testthat::expect_warning(get_default_fid())
  testthat::expect_warning(get_default_url())
  testthat::expect_warning(get_default_un())
  testthat::expect_warning(get_default_pw())
  testthat::expect_warning(get_default_tz())
  testthat::expect_warning(get_test_url())
  testthat::expect_warning(get_test_un())
  testthat::expect_warning(get_test_pw())
  testthat::expect_warning(get_test_pid())
  testthat::expect_warning(get_test_fid())
  testthat::expect_warning(get_test_fid_zip())
  testthat::expect_warning(get_test_fid_att())
  testthat::expect_warning(get_test_fid_gap())

  testthat::expect_equal(x$url, "")
  testthat::expect_equal(x$un, "")
  testthat::expect_equal(x$pw, "")
  testthat::expect_equal(x$tz, "")
  testthat::expect_equal(x$test_url, "")
  testthat::expect_equal(x$test_un, "")
  testthat::expect_equal(x$test_pw, "")
  testthat::expect_equal(x$test_pid, "")
  testthat::expect_equal(x$test_fid, "")
  testthat::expect_equal(x$test_fid_zip, "")
  testthat::expect_equal(x$test_fid_att, "")
  testthat::expect_equal(x$test_fid_gap, "")
  testthat::expect_equal(x$verbose, FALSE)


  # Reset
  ru_setup(
    url = url,
    un = un,
    pw = pw,
    tz = tz,
    test_url = test_url,
    test_un = test_un,
    test_pw = test_pw,
    test_pid = test_pid,
    test_fid = test_fid,
    test_fid_zip = test_fid_zip,
    test_fid_att = test_fid_att,
    test_fid_gap = test_fid_gap,
    verbose = TRUE
  )
})

test_that("ru_setup sets pid, fid, url if given service url", {

  # Save sane state
  test_pid <- get_test_pid()
  test_fid <- get_test_fid()
  test_fid_zip <- get_test_fid_zip()
  test_fid_att <- get_test_fid_att()
  test_url <- get_test_url()

  # Hammertime
  ru_setup(
    svc = "https://defaultserver.com/v1/projects/20/forms/FORMID.svc",
    test_svc = "https://testserver.com/v1/projects/40/forms/TESTFORMID.svc",
    verbose = TRUE
  )
  x <- ru_settings()

  testthat::expect_equal(x$url, "https://defaultserver.com")
  testthat::expect_equal(x$pid, "20")
  testthat::expect_equal(x$fid, "FORMID")
  testthat::expect_equal(x$test_url, "https://testserver.com")
  testthat::expect_equal(x$test_pid, "40")
  testthat::expect_equal(x$test_fid, "TESTFORMID")
  testthat::expect_equal(x$verbose, TRUE)


  # Restore sane state
  ru_setup(
    test_url = test_url,
    test_pid = test_pid,
    test_fid = test_fid,
    test_fid_zip = test_fid_zip,
    test_fid_att = test_fid_att
  )
})

test_that("ru_setup sets individual settings", {

  ru_setup(verbose = FALSE)
  testthat::expect_equal(get_ru_verbose(), FALSE)

  ru_setup(verbose = TRUE)
  testthat::expect_equal(get_ru_verbose(), TRUE)


  # Keep original test settings
  url <- get_test_url()

  # Hammertime
  xx <- "something"
  ru_setup(url = xx)
  testthat::expect_equal(ru_settings()$url, xx)

  # Reset
  ru_setup(url = url)
})

test_that("ru_settings prints nicely", {
  x <- ru_settings()
  testthat::expect_equal(class(x), "ru_settings")

  out <- testthat::capture_output(print(x))
  testthat::expect_match(out, "ruODK settings")
})

test_that("yell_if_missing yells loudly", {
  testthat::expect_error(yell_if_missing("", "username", "password"))
  testthat::expect_error(yell_if_missing("url", "", "password"))
  testthat::expect_error(yell_if_missing("url", "username", ""))
  testthat::expect_error(yell_if_missing(NULL, "", ""))
  testthat::expect_error(yell_if_missing("", "", ""))
  testthat::expect_error(yell_if_missing("", "", "", ""))
  testthat::expect_error(yell_if_missing("", "", "", "", ""))
  testthat::expect_error(yell_if_missing("x", "x", "x", pid = "", fid = "x"))
  testthat::expect_error(yell_if_missing("x", "x", "x", pid = "x", fid = ""))
  testthat::expect_error(
    yell_if_missing("x", "x", "x", pid = "x", fid = "x", iid = "")
  )
})

test_that("odata_svc_parse works", {
  svc_url <- paste0(
    "https://sandbox.central.opendatakit.org/v1/projects/14/",
    "forms/build_Flora-Quadrat-0-2_1558575936.svc"
  )
  x <- odata_svc_parse(svc_url)
  testthat::expect_equal(x$url, "https://sandbox.central.opendatakit.org")
  testthat::expect_equal(x$pid, "14")
  testthat::expect_equal(x$fid, "build_Flora-Quadrat-0-2_1558575936")

  svc_url <- "https://central.org/v1/projects/5/forms/formid.svc"
  x <- odata_svc_parse(svc_url)
  testthat::expect_equal(x$url, "https://central.org")
  testthat::expect_equal(x$pid, "5")
  testthat::expect_equal(x$fid, "formid")
})

test_that("ru_settings prints only if verbose", {
  testthat::expect_output(ru_setup(verbose = TRUE))

  testthat::expect_equal(
    testthat::capture_output(ru_setup(verbose = FALSE)),
    ""
  )

})

# usethis::edit_file("R/ru_setup.R")
