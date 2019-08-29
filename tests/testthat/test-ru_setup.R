test_that("ru_setup does not update settings if given NULL", {
  xx <- ru_settings()

  # This does not change settings
  ru_setup(
    url = NULL,
    un = NULL,
    pw = NULL,
    test_url = NULL,
    test_un = NULL,
    test_pw = NULL,
    test_pid = NULL,
    test_fid = NULL
  )

  # Get current (unchanged) settings
  x <- ru_settings()

  # Settings are still the default/test settings
  testthat::expect_equal(x$url, get_default_url())
  testthat::expect_equal(xx$url, get_default_url())

  testthat::expect_equal(x$un, get_default_un())
  testthat::expect_equal(x$pw, get_default_pw())
  testthat::expect_equal(x$test_url, get_test_url())
  testthat::expect_equal(x$test_un, get_test_un())
  testthat::expect_equal(x$test_pw, get_test_pw())
  testthat::expect_equal(x$test_pid, get_test_pid())
  testthat::expect_equal(x$test_fid, get_test_fid())
})

test_that("ru_setup resets settings if given empty string", {

  # Keep original test settings
  url <- get_default_url()
  un <- get_default_un()
  pw <- get_default_pw()
  test_url <- get_test_url()
  test_un <- get_test_un()
  test_pw <- get_test_pw()
  test_pid <- get_test_pid()
  test_fid <- get_test_fid()

  # Hammertime
  ru_setup(
    url = "",
    un = "",
    pw = "",
    test_url = "",
    test_un = "",
    test_pw = "",
    test_pid = "",
    test_fid = ""
  )
  x <- ru_settings()

  # Yell at me
  testthat::expect_warning(get_default_url())
  testthat::expect_warning(get_default_un())
  testthat::expect_warning(get_default_pw())
  testthat::expect_warning(get_test_url())
  testthat::expect_warning(get_test_un())
  testthat::expect_warning(get_test_pw())
  testthat::expect_warning(get_test_pid())
  testthat::expect_warning(get_test_fid())

  testthat::expect_equal(x$url, "")
  testthat::expect_equal(x$un, "")
  testthat::expect_equal(x$pw, "")
  testthat::expect_equal(x$test_url, "")
  testthat::expect_equal(x$test_un, "")
  testthat::expect_equal(x$test_pw, "")
  testthat::expect_equal(x$test_pid, "")
  testthat::expect_equal(x$test_fid, "")

  # Reset
  ru_setup(
    url = url,
    un = un,
    pw = pw,
    test_url = test_url,
    test_un = test_un,
    test_pw = test_pw,
    test_pid = test_pid,
    test_fid = test_fid
  )
})

test_that("ru_setup sets individual settings", {

  # Keep original test settings
  url <- get_default_url()

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
  testthat::expect_error(
    yell_if_missing("asd", "asd", "asd", pid = "", fid = "asd")
  )
  testthat::expect_error(
    yell_if_missing("asd", "asd", "asd", pid = "asd", fid = "")
  )
})
