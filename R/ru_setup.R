#' Get or set \code{ruODK} settings.
#'
#' @export
#' @return \code{ru_settings} prints your default ODK Central url, username,
#' and password, and corresponding optional test server settings.
#' \code{ru_setup} sets your production and test settings, while
#' \code{get_(test_)*} get each of those respective settings.
#' @seealso  \code{\link{ru_setup}},
#' \code{\link{get_default_url}},
#' \code{\link{get_default_un}},
#' \code{\link{get_default_pw}},
#' \code{\link{get_test_url}},
#' \code{\link{get_test_un}},
#' \code{\link{get_test_pw}},
#' \code{\link{get_test_pid}},
#' \code{\link{get_test_fid}}.
#' @family ru_settings
#' @examples
#' ru_settings()
ru_settings <- function() {
  ops <- list(
    url = Sys.getenv("ODKC_URL", ""),
    un = Sys.getenv("ODKC_UN", ""),
    pw = Sys.getenv("ODKC_PW", ""),
    test_url = Sys.getenv("ODKC_TEST_URL", ""),
    test_un = Sys.getenv("ODKC_TEST_UN", ""),
    test_pw = Sys.getenv("ODKC_TEST_PW", ""),
    test_pid = Sys.getenv("ODKC_TEST_PID", ""),
    test_fid = Sys.getenv("ODKC_TEST_FID", "")
  )
  structure(ops, class = "ru_settings")
}

#' @export
print.ru_settings <- function(x, ...) {
  cat("<ruODK settings>", sep = "\n")
  cat("  Default ODK Central URL: ", x$url, "\n")
  cat("  Default ODK Central Username: ", x$un, "\n")
  cat("  Default ODK Central Password: ", x$pw, "\n")
  cat("  Test ODK Central URL:", x$test_url, "\n")
  cat("  Test ODK Central Username:", x$test_un, "\n")
  cat("  Test ODK Central Password:", x$test_pw, "\n")
  cat("  Test ODK Central Project ID:", x$test_pid, "\n")
  cat("  Test ODK Central Form ID:", x$test_fid, "\n")
}

#------------------------------------------------------------------------------#
# Setters
#
#' Configure default \code{ruODK} settings.
#'
#' @export
#' @param url An ODK Central URL, e.g. "https://sandbox.central.opendatakit.org".
#' @param un An ODK Central username which is the email of a "web user" in the
#'   specified ODK Central instance \code{url} (optional, character).
#' @param pw The password for user \code{un} (optional, character).
#' @param test_url (optional, character) A valid ODK Central URL for testing.
#' @param test_un (optional, character) A valid ODK Central username (email)
#'   privileged to view the test project(s) at \code{test_url}.
#' @param test_pw (optional, character) The valid ODK Central password for
#'   \code{test_un}.
#' @param test_pid (optional, integer) The numeric ID of an existing project on
#'   \code{test_url}.
#' @param test_fid (optional, character) The alphanumeric ID of an existing form
#'   in \code{test_pid}.
#' @family ru_settings
#' @details
#' \code{ru_setup} sets ODK Central connection details. \code{ruODK}'s functions
#'   default to use the default URL, username, and password unless specified
#'   explicitly.
#'
#' \code{ruODK}'s automated tests require a valid ODK Central URL, and a
#'   privileged username and password of a "web user" on that ODK Central
#'   instance, as well as an existing project and form.
#'
#' @examples
#' # \code{ruODK} users only need default settings to their ODK Central instance:
#' ru_setup(url = "https://my-odkc.com", un = "me@email.com", pw = "...")
#'
#' # \code{ruODK} contributors and maintainers need specific ODK Central instances
#' # to run tests and build vignettes, see contributing guide:
#' ru_setup(
#'   url = "https://odkcentral.dbca.wa.gov.au",
#'   un = "me@email.com",
#'   pw = "...",
#'   test_url = "https://sandbox.central.opendatakit.org",
#'   test_un = "me@email.com",
#'   test_pw = "...",
#'   test_pid = 14,
#'   test_fid = "build_Flora-Quadrat-0-2_1558575936"
#' )
ru_setup <- function(url = NULL,
                     un = NULL,
                     pw = NULL,
                     test_url = NULL,
                     test_un = NULL,
                     test_pw = NULL,
                     test_pid = NULL,
                     test_fid = NULL) {
  if (!is.null(url)) Sys.setenv("ODKC_URL" = url)
  if (!is.null(un)) Sys.setenv("ODKC_UN" = un)
  if (!is.null(pw)) Sys.setenv("ODKC_PW" = pw)
  if (!is.null(test_url)) Sys.setenv("ODKC_TEST_URL" = test_url)
  if (!is.null(test_un)) Sys.setenv("ODKC_TEST_UN" = test_un)
  if (!is.null(test_pw)) Sys.setenv("ODKC_TEST_PW" = test_pw)
  if (!is.null(test_pid)) Sys.setenv("ODKC_TEST_PID" = test_pid)
  if (!is.null(test_fid)) Sys.setenv("ODKC_TEST_FID" = test_fid)
}

#------------------------------------------------------------------------------#
# Getters
#
#' @export
#' @rdname ru_settings
get_default_url <- function() {
  x <- Sys.getenv("ODKC_URL")
  if (identical(x, "")) {
    rlang::warn("No default ODK Central URL set. ru_setup()?")
  }
  x
}

#' @export
#' @rdname ru_settings
get_default_un <- function() {
  x <- Sys.getenv("ODKC_UN")
  if (identical(x, "")) {
    rlang::warn("No default ODK Central username set. ru_setup()?")
  }
  x
}

#' @export
#' @rdname ru_settings
get_default_pw <- function() {
  x <- Sys.getenv("ODKC_PW")
  if (identical(x, "")) {
    rlang::warn("No default ODK Central password set. ru_setup()?")
  }
  x
}

#' @export
#' @rdname ru_settings
get_test_url <- function() {
  x <- Sys.getenv("ODKC_TEST_URL")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central URL set. ru_setup()?")
  }
  x
}

#' @export
#' @rdname ru_settings
get_test_un <- function() {
  x <- Sys.getenv("ODKC_TEST_UN")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central username set. ru_setup()?")
  }
  x
}

#' @export
#' @rdname ru_settings
get_test_pw <- function() {
  x <- Sys.getenv("ODKC_TEST_PW")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central password set. ru_setup()?")
  }
  x
}

#' @export
#' @rdname ru_settings
get_test_pid <- function() {
  x <- Sys.getenv("ODKC_TEST_PID")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central project ID set. ru_setup()?")
  }
  x
}

#' @export
#' @rdname ru_settings
get_test_fid <- function() {
  x <- Sys.getenv("ODKC_TEST_FID")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central form ID set. ru_setup()?")
  }
  x
}

#' Abort on missing ODK Central credentials (url, username, password).
#'
#' @param url A URL (character)
#' @param un A username (character)
#' @param pw A password (character)
#' @param pid A project ID (numeric, optional)
#' @param fid A form ID (character, optional)
#' @details This is a helper function to pat down \code{ruODK} functions for
#'          missing credentials and stop with a loud but informative yell.
#' @family ru_settings
#' @export
#' @examples
#' testthat::expect_error(yell_if_missing("", "username", "password"))
#' testthat::expect_error(yell_if_missing("url", "", "password"))
#' testthat::expect_error(yell_if_missing("url", "username", ""))
#' testthat::expect_error(yell_if_missing(NULL, "", ""))
#' testthat::expect_error(yell_if_missing("", "", ""))
#' testthat::expect_error(yell_if_missing("", "", "", ""))
#' testthat::expect_error(yell_if_missing("", "", "", "", ""))
yell_if_missing <- function(url, un, pw, pid = NULL, fid = NULL) {
  if (is.null(url) | identical(url, "")) {
    rlang::abort("Missing ODK Central URL. ru_setup()?")
  }
  if (is.null(un) | identical(un, "")) {
    rlang::abort("Missing ODK Central username. ru_setup()?")
  }
  if (is.null(pw) | identical(pw, "")) {
    rlang::abort("Missing ODK Central password. ru_setup()?")
  }
  if (!is.null(pid) && identical(pid, "")) {
    rlang::abort("Missing ODK Central project ID. ru_setup()?")
  }
  if (!is.null(fid) && identical(fid, "")) {
    rlang::abort("Missing ODK Central form ID. ru_setup()?")
  }
}

#' Warn about failed web requests and give helpful troubleshooting tips.
#'
#' A wrapper around \code{httr::stop_for_status()} with a helpful error message.
#' Examples: see tests for \code{ruODK::project_list()}.
#' This function is used internally but may be useful for debugging and
#' \code{ruODK} development.
#' @param response A httr response object
#' @param url A URL (character)
#' @param un A username (character)
#' @param pw A password (character)
#' @param pid A project ID (numeric, optional)
#' @param fid A form ID (character, optional)
#' @return The response object
#' @family ru_settings
yell_if_error <- function(response, url, un, pw, pid = NULL, fid = NULL){
  response %>%
    httr::stop_for_status(
      task = glue::glue(
        "connect to {url} as user {un} with password {pw}.\n",
        "This request failed likely on incorrect credentials (url, un, pw).\n",
        "Troubleshooting tips:\n",
        "If you have used this function with default settings, ",
        "check ru_settings() and run ru_setup() with working credentials.\n",
        'Read the vignette("Setup", package = "ruODK") for details of setting ',
        "up ruODK")
    )
}
