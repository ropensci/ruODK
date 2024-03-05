test_that("ru_setup does not update settings if given NULL", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  xx <- ru_settings()

  # This does not change settings
  ru_setup(
    svc = NULL,
    pid = NULL,
    fid = NULL,
    url = NULL,
    un = NULL,
    pw = NULL,
    pp = NULL,
    tz = NULL,
    odkc_version = NULL,
    verbose = NULL,
    retries = NULL,
    test_svc = NULL,
    test_pid = NULL,
    test_fid = NULL,
    test_fid_zip = NULL,
    test_fid_att = NULL,
    test_fid_gap = NULL,
    test_fid_wkt = NULL,
    test_url = NULL,
    test_un = NULL,
    test_pw = NULL,
    test_pp = NULL,
    test_odkc_version = NULL
  )

  # Get current (unchanged) settings
  x <- ru_settings()

  # Settings are still the default/test settings
  # If env vars not set, default getters will issue warnings
  testthat::expect_equal(x$url, xx$url)
  testthat::expect_equal(x$un, xx$un)
  testthat::expect_equal(x$pw, xx$pw)
  testthat::expect_equal(x$pp, xx$pp)
  testthat::expect_equal(x$odkc_version, xx$odkc_version)
  testthat::expect_equal(x$tz, xx$tz)
  testthat::expect_equal(x$test_url, xx$test_url)
  testthat::expect_equal(x$test_un, xx$test_un)
  testthat::expect_equal(x$test_pw, xx$test_pw)
  testthat::expect_equal(x$test_pp, xx$test_pp)
  testthat::expect_equal(x$test_odkc_version, xx$test_odkc_version)
  testthat::expect_equal(x$retries, xx$retries)
  testthat::expect_equal(x$test_pid, xx$test_pid)
  testthat::expect_equal(x$test_fid, xx$test_fid)
  testthat::expect_equal(x$test_fid_zip, xx$test_fid_zip)
  testthat::expect_equal(x$test_fid_att, xx$test_fid_att)
  testthat::expect_equal(x$test_fid_gap, xx$test_fid_gap)
  testthat::expect_equal(x$test_fid_wkt, xx$test_fid_wkt)
  testthat::expect_equal(x$verbose, xx$verbose)
})

test_that("ru_setup resets settings if given empty string", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # Keep original test settings
  url <- get_default_url()
  un <- get_default_un()
  pw <- get_default_pw()
  pp <- get_default_pp()
  tz <- get_default_tz()
  odkcv <- get_default_odkc_version()
  retries <- get_retries()
  verbose <- get_ru_verbose()
  retries <- get_retries()
  test_url <- get_test_url()
  test_un <- get_test_un()
  test_pw <- get_test_pw()
  test_pp <- get_test_pp()
  test_odkcv <- get_test_odkc_version()
  test_pid <- get_test_pid()
  test_fid <- get_test_fid()
  test_fid_zip <- get_test_fid_zip()
  test_fid_att <- get_test_fid_att()
  test_fid_gap <- get_test_fid_gap()
  test_fid_wkt <- get_test_fid_wkt()

  # Hammertime
  ru_setup(
    pid = "",
    fid = "",
    url = "",
    un = "",
    pw = "",
    pp = "",
    tz = "",
    odkc_version = "",
    retries = "",
    verbose = TRUE,
    test_pid = "",
    test_fid = "",
    test_fid_zip = "",
    test_fid_att = "",
    test_fid_gap = "",
    test_fid_wkt = "",
    test_url = "",
    test_un = "",
    test_pw = "",
    test_pp = "",
    test_odkc_version = ""
  )
  x <- ru_settings()

  # Yell at me
  testthat::expect_warning(get_default_pid())
  testthat::expect_warning(get_default_fid())
  testthat::expect_warning(get_default_url())
  testthat::expect_warning(get_default_un())
  testthat::expect_warning(get_default_pw())
  testthat::expect_warning(get_default_pp())
  # testthat::expect_warning(get_default_odkc_version()) # nolint
  testthat::expect_warning(get_default_tz())
  testthat::expect_equal(get_retries(), 3L) # fallback for empty RU_RETRIES
  testthat::expect_warning(get_test_url())
  testthat::expect_warning(get_test_un())
  testthat::expect_warning(get_test_pw())
  testthat::expect_warning(get_test_pp())
  # testthat::expect_warning(get_test_odkc_version()) # nolint
  testthat::expect_warning(get_test_pid())
  testthat::expect_warning(get_test_fid())
  testthat::expect_warning(get_test_fid_zip())
  testthat::expect_warning(get_test_fid_att())
  testthat::expect_warning(get_test_fid_gap())
  testthat::expect_warning(get_test_fid_wkt())

  testthat::expect_equal(x$url, "")
  testthat::expect_equal(x$un, "")
  testthat::expect_equal(x$pw, "")
  testthat::expect_equal(x$pp, "")
  # testthat::expect_equal(x$tz, "") # nolint
  testthat::expect_equal(x$test_url, "")
  testthat::expect_equal(x$test_un, "")
  testthat::expect_equal(x$test_pw, "")
  testthat::expect_equal(x$test_pp, "")
  testthat::expect_equal(x$test_pid, "")
  testthat::expect_equal(x$test_fid, "")
  testthat::expect_equal(x$test_fid_zip, "")
  testthat::expect_equal(x$test_fid_att, "")
  testthat::expect_equal(x$test_fid_gap, "")
  testthat::expect_equal(x$test_fid_wkt, "")
  testthat::expect_equal(x$verbose, TRUE)


  # Reset
  ru_setup(
    url = url,
    un = un,
    pw = pw,
    pp = pp,
    tz = tz,
    odkc_version = odkcv,
    retries = retries,
    test_url = test_url,
    test_un = test_un,
    test_pw = test_pw,
    test_pp = test_pp,
    test_odkc_version = test_odkcv,
    test_pid = test_pid,
    test_fid = test_fid,
    test_fid_zip = test_fid_zip,
    test_fid_att = test_fid_att,
    test_fid_gap = test_fid_gap,
    test_fid_wkt = test_fid_wkt,
    verbose = TRUE
  )
})

test_that("get_default_tz warns and defaults to UTC if tz set to ''", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # tz0 <- get_default_tz()s
  # testthat::expect_equal(tz0, "UTC") # TZ is not set in tests # nolint

  # Override tz
  ru_setup(tz = "")
  suppressWarnings(tz1 <- get_default_tz())
  testthat::expect_equal(tz1, "UTC")
  testthat::expect_warning(get_default_tz())

  ru_setup(tz = "UTC")
  # No warnings if explicitly set
  testthat::expect_equal(get_default_tz(), "UTC")

  ru_setup(tz = "Australia/Perth")
  testthat::expect_equal(get_default_tz(), "Australia/Perth")
})

test_that("ru_setup sets pid, fid, url if given service url", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )
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
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

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
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

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
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  testthat::expect_output(ru_setup(verbose = TRUE))

  testthat::expect_equal(
    testthat::capture_output(ru_setup(verbose = FALSE)),
    ""
  )
})

test_that("retries default to 1L if empty or invalid", {
  skip_if(Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  # Keep a memory of better times
  retries <- get_retries()
  ru_msg_info(glue::glue("Env var retries: {Sys.getenv('RU_RETRIES')}"))
  ru_msg_info(glue::glue("get_retries(): {get_retries()}"))

  # That's not a number
  ru_setup(retries = "")
  ru_msg_info(glue::glue("Env var retries: {Sys.getenv('RU_RETRIES')}"))
  ru_msg_info(glue::glue("get_retries(): {get_retries()}"))
  testthat::expect_equal(get_retries(), 3L)

  # Not a number
  ru_setup(retries = "a")
  ru_msg_info(glue::glue("Env var retries: {Sys.getenv('RU_RETRIES')}"))
  ru_msg_info(glue::glue("get_retries(): {get_retries()}"))
  testthat::expect_equal(get_retries(), 3L)

  # That's better
  ru_setup(retries = 5)
  ru_msg_info(glue::glue("Env var retries: {Sys.getenv('RU_RETRIES')}"))
  ru_msg_info(glue::glue("get_retries(): {get_retries()}"))
  testthat::expect_equal(get_retries(), 5L)

  # Restore law and order
  ru_setup(retries = retries)
  ru_msg_info(glue::glue("Env var retries: {Sys.getenv('RU_RETRIES')}"))
  ru_msg_info(glue::glue("get_retries(): {get_retries()}"))
})

testthat::test_that("semver_gt compares ODKC versions", {
  testthat::expect_true("2024.1.1" |> semver_gt("2020.1.0"))
  testthat::expect_true("2024.1.1" |> semver_gt("2020.1.1"))
  testthat::expect_false("2024.1.1" |> semver_gt("2024.1.2"))
  testthat::expect_true(get_test_odkc_version() |> semver_gt("0.8.0"))
})

testthat::test_that("semver_lt compares ODKC versions", {
  testthat::expect_false("2024.1.1" |> semver_lt("2020.1.0"))
  testthat::expect_false("2024.1.1" |> semver_lt("2020.1.1"))
  testthat::expect_true("2024.1.1" |> semver_lt("2024.1.2"))
  testthat::expect_false(get_default_odkc_version() |> semver_lt("0.8.0"))
})

# usethis::use_r("ru_setup") # nolint
