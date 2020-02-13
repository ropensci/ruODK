#' Get or set \code{ruODK} settings.
#'
#' \lifecycle{stable}
#'
#' @export
#' @return \code{\link{ru_settings}} prints your default ODK Central project ID,
#'   form ID, url, username, and password, corresponding optional test
#'   server as well as verbosity settings.
#' \code{\link{ru_setup}} sets your production and test settings, while
#' \code{get_(default/test)_*} get each of those respective settings.
#' @seealso  \code{\link{ru_setup}},
#' \code{\link{get_default_pid}},
#' \code{\link{get_default_fid}},
#' \code{\link{get_default_url}},
#' \code{\link{get_default_un}},
#' \code{\link{get_default_pw}},
#' \code{\link{get_default_tz}},
#' \code{\link{get_test_pid}},
#' \code{\link{get_test_fid}},
#' \code{\link{get_test_fid_zip}},
#' \code{\link{get_test_fid_att}},
#' \code{\link{get_test_fid_gap}},
#' \code{\link{get_test_url}},
#' \code{\link{get_test_un}},
#' \code{\link{get_test_pw}},
#' \code{\link{get_ru_verbose}}.
#' @family ru_settings
#' @examples
#' ru_settings()
ru_settings <- function() {
  ops <- list(
    pid = Sys.getenv("ODKC_PID", ""),
    fid = Sys.getenv("ODKC_FID", ""),
    url = Sys.getenv("ODKC_URL", ""),
    un = Sys.getenv("ODKC_UN", ""),
    pw = Sys.getenv("ODKC_PW", ""),
    tz = Sys.getenv("RU_TIMEZONE", "UTC"),
    test_pid = Sys.getenv("ODKC_TEST_PID", ""),
    test_fid = Sys.getenv("ODKC_TEST_FID", ""),
    test_fid_zip = Sys.getenv("ODKC_TEST_FID_ZIP", ""),
    test_fid_att = Sys.getenv("ODKC_TEST_FID_ATT", ""),
    test_fid_gap = Sys.getenv("ODKC_TEST_FID_GAP", ""),
    test_url = Sys.getenv("ODKC_TEST_URL", ""),
    test_un = Sys.getenv("ODKC_TEST_UN", ""),
    test_pw = Sys.getenv("ODKC_TEST_PW", ""),
    verbose = as.logical(Sys.getenv("RU_VERBOSE", FALSE))
  )
  structure(ops, class = "ru_settings")
}

#' @export
print.ru_settings <- function(x, ...) {
  cat("<ruODK settings>", sep = "\n")
  cat("  Default ODK Central Project ID: ", x$pid, "\n")
  cat("  Default ODK Central Form ID: ", x$fid, "\n")
  cat("  Default ODK Central URL: ", x$url, "\n")
  cat("  Default ODK Central Username: ", x$un, "\n")
  cat("  Default ODK Central Password: run ruODK::get_default_pw() to show \n")
  cat("  Default Time Zone: ", x$tz, "\n")
  cat("  Test ODK Central Project ID:", x$test_pid, "\n")
  cat("  Test ODK Central Form ID:", x$test_fid, "\n")
  cat("  Test ODK Central Form ID (ZIP tests):", x$test_fid_zip, "\n")
  cat("  Test ODK Central Form ID (Attachment tests):", x$test_fid_att, "\n")
  cat("  Test ODK Central Form ID (Parsing tests):", x$test_fid_gap, "\n")
  cat("  Test ODK Central URL:", x$test_url, "\n")
  cat("  Test ODK Central Username:", x$test_un, "\n")
  cat("  Test ODK Central Password: run ruODK::get_test_pw() to show \n")
  cat("  Verbose messages:", x$verbose, "\n")
}

#------------------------------------------------------------------------------#
# Helpers
#
#' Retrieve URL, project ID, and form ID from an ODK Central OData service URL.
#'
#' \lifecycle{stable}
#'
#' @param svc (character) The OData service URL of a form as provided by the
#'   ODK Central form submissions tab.
# nolint start
#'   Example: "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-2_1558575936.svc"
# nolint end
#' @export
#' @family ru_settings
#' @return A named list with three components (all of type character):
#'
#'   * \code{url} The ODK Central base URL.
#'   * \code{pid} The project ID.
#'   * \code{fid} The form ID.
odata_svc_parse <- function(svc) {
  parts <- httr::parse_url(svc)
  pth <- parts$path %>% stringr::str_split("/")
  list(
    url = glue::glue("{parts$scheme}://{parts$hostname}"),
    pid = pth[[1]][[3]],
    fid = pth[[1]][[5]] %>% fs::path_ext_remove(.)
  )
}

#------------------------------------------------------------------------------#
# Setters
#
#' Configure default \code{\link{ruODK}} settings.
#'
#' Settings are returned invisibly and additionally printed depending on
#' \code{\link{get_ru_verbose}}.
#'
#' \lifecycle{stable}
#'
#' @export
#' @param svc (optional, character) The OData service URL of a form.
#'   This parameter will set \code{pid}, \code{fid}, and \code{url}.
#'   It is sufficient to supply \code{svc}, \code{un}, and \code{pw}.
#' @param pid (optional, character) The ID of an existing project on \code{url}.
#'   This will override the project ID from \code{svc}.
#'   A numeric value for \code{pid} will be converted to character.
#' @param fid (optional, character) The alphanumeric ID of an existing form
#'   in \code{pid}. This will override the form ID from \code{svc}.
#' @param url An ODK Central URL,
#'   e.g. "https://sandbox.central.opendatakit.org".
#'   This will override the ODK Central base URL from \code{svc}.
#' @param un An ODK Central username which is the email of a "web user" in the
#'   specified ODK Central instance \code{url} (optional, character).
#' @param pw The password for user \code{un} (optional, character).
#' @param tz Global default time zone.
#'   `ruODK`'s time zone is determined in order of precedence:
#'     * Function parameter:
#'       e.g. \code{\link{odata_submission_get}(tz = "Australia/Perth")}
#'     * `ruODK` setting: \code{\link{ru_setup}(tz = "Australia/Perth")}
#'     * Environment variable `RU_TIMEZONE` (e.g. set in `.Renviron`)
#'     * `GMT`.
#' @param test_svc (optional, character) The OData service URL of a test form.
#'   This parameter will set \code{test_pid}, \code{test_fid}, and
#'   \code{test_url}. It is sufficient to supply \code{test_svc},
#'   \code{test_un}, and \code{test_pw} to configure testing.
#' @param test_pid (optional, character) The numeric ID of an existing project
#'   on \code{test_url}. This will override the project ID from \code{test_svc}.
#'   A numeric value for \code{test_pid} will be converted to character.
#' @param test_fid (optional, character) The alphanumeric ID of an existing form
#'   in \code{test_pid}. This will override the form ID from \code{test_svc}.
#'   This form is used as default form in all tests, examples, vignettes, data,
#'   and Rmd templates.
#' @param test_fid_zip (optional, character) The alphanumeric ID of an existing
#'   form in \code{test_pid}. This will override the form ID from
#'   \code{test_svc}.
#'   Provide the form ID of a form with few submissions and without attachments.
#'   This form is used to test the repeated download of all form submissions.
#' @param test_fid_att (optional, character) The alphanumeric ID of an existing
#'   form in \code{test_pid}. This will override the form ID from
#'   \code{test_svc}.
#'   Provide the form ID of a form with few submissions and few attachments.
#'   This form is used to test downloading and linking attachments.
#' @param test_fid_gap (optional, character) The alphanumeric ID of an existing
#'   form in \code{test_pid}. This will override the form ID from
#'   \code{test_svc}.
#'   Provide the form ID of a form with gaps in the first submission.
#'   This form is used to test parsing incomplete submissions.
#' @param test_url (optional, character) A valid ODK Central URL for testing.
#'   This will override the ODK Central base URL from \code{svc}.
#' @param test_un (optional, character) A valid ODK Central username (email)
#'   privileged to view the test project(s) at \code{test_url}.
#' @param test_pw (optional, character) The valid ODK Central password for
#'   \code{test_un}.
#' @param verbose Global default for `ruODK` verbosity.
#'   `ruODK` verbosity is determined in order of precedence:
#'     * Function parameter:
#'       e.g. \code{\link{odata_submission_get}(verbose = TRUE)}
#'     * `ruODK` setting: \code{\link{ru_setup}(verbose = TRUE)}
#'     * Environment variable `RU_VERBOSE` (e.g. set in `.Renviron`)
#'     * `FALSE`.
#' @family ru_settings
#' @details
#' \code{\link{ru_setup}} sets ODK Central connection details.
#'   \code{\link{ruODK}}'s functions default to use the default project ID,
#'   form ID, URL, username, and password unless specified explicitly.
#'
#' Any parameters not specified will remain unchanged. It is therefore possible
#' to set up username and password initially with
#' \code{ru_setup(un="XXX", pw="XXX")}, and switch between forms with
#' \code{ru_setup(svc="XXX")}, supplying the form's OData service URL.
#' ODK Central conveniently provides the OData service URL in the form
#' submission tab, which in turn contains base URL, project ID, and form ID.
#'
#' \code{\link{ruODK}}'s automated tests require a valid ODK Central URL, and a
#'   privileged username and password of a "web user" on that ODK Central
#'   instance, as well as an existing project and form.
#'
#' @examples
#' # `ruODK` users only need default settings to their ODK Central:
#' ru_setup(url = "https://my-odkc.com", un = "me@email.com", pw = "...")
#'
#' # `ruODK` contributors and maintainers need specific ODK Central
#' # instances to run tests and build vignettes, see contributing guide:
#' ru_setup(
#'   url = "https://odkcentral.dbca.wa.gov.au",
#'   un = "me@email.com",
#'   pw = "...",
#'   test_url = "https://sandbox.central.opendatakit.org",
#'   test_un = "me@email.com",
#'   test_pw = "...",
#'   test_pid = 14,
#'   test_fid = "build_Flora-Quadrat-0-2_1558575936",
#'   test_fid_zip = "build_Spotlighting-0-6_1558333698",
#'   test_fid_att = "build_Flora-Quadrat-0-1_1558330379",
#'   verbose = TRUE
#' )
ru_setup <- function(svc = NULL,
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
                     verbose = NULL) {
  if (!is.null(svc)) {
    odata_components <- odata_svc_parse(svc)
    Sys.setenv("ODKC_PID" = odata_components$pid)
    Sys.setenv("ODKC_FID" = odata_components$fid)
    Sys.setenv("ODKC_URL" = odata_components$url)
  }

  if (!is.null(pid)) Sys.setenv("ODKC_PID" = as.character(pid))
  if (!is.null(fid)) Sys.setenv("ODKC_FID" = fid)
  if (!is.null(url)) Sys.setenv("ODKC_URL" = url)
  if (!is.null(un)) Sys.setenv("ODKC_UN" = un)
  if (!is.null(pw)) Sys.setenv("ODKC_PW" = pw)
  if (!is.null(tz)) Sys.setenv("RU_TIMEZONE" = tz)

  if (!is.null(test_svc)) {
    odata_components <- odata_svc_parse(test_svc)
    Sys.setenv("ODKC_TEST_PID" = odata_components$pid)
    Sys.setenv("ODKC_TEST_FID" = odata_components$fid)
    Sys.setenv("ODKC_TEST_URL" = odata_components$url)
  }

  if (!is.null(test_pid)) Sys.setenv("ODKC_TEST_PID" = as.character(test_pid))
  if (!is.null(test_fid)) Sys.setenv("ODKC_TEST_FID" = test_fid)
  if (!is.null(test_fid_zip)) Sys.setenv("ODKC_TEST_FID_ZIP" = test_fid_zip)
  if (!is.null(test_fid_att)) Sys.setenv("ODKC_TEST_FID_ATT" = test_fid_att)
  if (!is.null(test_fid_gap)) Sys.setenv("ODKC_TEST_FID_GAP" = test_fid_gap)
  if (!is.null(test_url)) Sys.setenv("ODKC_TEST_URL" = test_url)
  if (!is.null(test_un)) Sys.setenv("ODKC_TEST_UN" = test_un)
  if (!is.null(test_pw)) Sys.setenv("ODKC_TEST_PW" = test_pw)
  if (!is.null(verbose)) Sys.setenv("RU_VERBOSE" = verbose)

  if (get_ru_verbose()) {
    print(ru_settings())
  }
}

#------------------------------------------------------------------------------#
# Getters
#
#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_default_pid <- function() {
  x <- Sys.getenv("ODKC_PID")
  if (identical(x, "")) {
    rlang::warn("No default ODK Central Project ID set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_default_fid <- function() {
  x <- Sys.getenv("ODKC_FID")
  if (identical(x, "")) {
    rlang::warn("No default ODK Central Form ID set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_default_url <- function() {
  x <- Sys.getenv("ODKC_URL")
  if (identical(x, "")) {
    rlang::warn("No default ODK Central URL set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_default_un <- function() {
  x <- Sys.getenv("ODKC_UN")
  if (identical(x, "")) {
    rlang::warn("No default ODK Central username set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_default_pw <- function() {
  x <- Sys.getenv("ODKC_PW")
  if (identical(x, "")) {
    rlang::warn("No default ODK Central password set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_default_tz <- function() {
  x <- Sys.getenv("RU_TIMEZONE", unset = "UTC")
  if (identical(x, "")) {
    rlang::warn("Empty ruODK timezone set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_test_url <- function() {
  x <- Sys.getenv("ODKC_TEST_URL")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central URL set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_test_un <- function() {
  x <- Sys.getenv("ODKC_TEST_UN")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central username set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_test_pw <- function() {
  x <- Sys.getenv("ODKC_TEST_PW")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central password set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_test_pid <- function() {
  x <- Sys.getenv("ODKC_TEST_PID")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central project ID set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_test_fid <- function() {
  x <- Sys.getenv("ODKC_TEST_FID")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central form ID set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_test_fid_zip <- function() {
  x <- Sys.getenv("ODKC_TEST_FID_ZIP")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central ZIP form ID set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_test_fid_att <- function() {
  x <- Sys.getenv("ODKC_TEST_FID_ATT")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central ATT form ID set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_test_fid_gap <- function() {
  x <- Sys.getenv("ODKC_TEST_FID_GAP")
  if (identical(x, "")) {
    rlang::warn("No test ODK Central GAP form ID set. ru_setup()?")
  }
  x
}

#' \lifecycle{stable}
#' @export
#' @rdname ru_settings
get_ru_verbose <- function() {
  x <- as.logical(Sys.getenv("RU_VERBOSE", unset = FALSE))
  x
}

#' Abort on missing ODK Central credentials (url, username, password).
#'
#' \lifecycle{stable}
#'
#' @param url A URL (character)
#' @param un A username (character)
#' @param pw A password (character)
#' @param pid A project ID (numeric, optional)
#' @param fid A form ID (character, optional)
#' @details This is a helper function to pat down \code{\link{ruODK}} functions
#'   for missing credentials and stop with a loud but informative yell.
#' @param iid A submission instance ID (character, optional)
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
#' testthat::expect_error(yell_if_missing("", "", "", "", "", ""))
yell_if_missing <- function(url, un, pw, pid = NULL, fid = NULL, iid = NULL) {
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
  if (!is.null(iid) && identical(iid, "")) {
    rlang::abort("Missing ODK Central submission instance ID.")
  }
}

#' Warn about failed web requests and give helpful troubleshooting tips.
#'
#' \lifecycle{stable}
#'
#' A wrapper around \code{httr::stop_for_status} with a more helpful error
#' message.
#' Examples: see tests for \code{\link{project_list}}.
#' This function is used internally but may be useful for debugging and
#' \code{\link{ruODK}} development.
#' @param response A httr response object
#' @param url A URL (character)
#' @param un A username (character)
#' @param pw A password (character)
#' @param pid A project ID (numeric, optional)
#' @param fid A form ID (character, optional)
#' @return The response object
#' @family ru_settings
yell_if_error <- function(response, url, un, pw, pid = NULL, fid = NULL) {
  response %>%
    httr::stop_for_status(
      task = glue::glue(
        "get desired response from server {url} as user \"{un}\".\n\n",
        "Troubleshooting tips:\n",
        "* Is the server online at {url}? Is the internet flaky? Retry!\n",
        "* Check ruODK::ru_settings() - credentials and defaults correct?\n",
        "* Run ru_setup() with working credentials and defaults.\n",
        '* Read the vignette("setup", package = "ruODK") how to set up ruODK.'
      )
    )
}

# Tests
# usethis::edit_file("tests/testthat/test-ru_setup.R")
