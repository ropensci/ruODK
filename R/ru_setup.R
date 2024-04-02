#' Get or set \code{ruODK} settings.
#'
#' `r lifecycle::badge("stable")`
#'
#' @export
#' @return \code{\link{ru_settings}} prints your default ODK Central project ID,
#'   form ID, url, username, and password, corresponding optional test
#'   server as well as verbosity and HTTP request settings.
#' \code{\link{ru_setup}} sets your production and test settings, while
#' \code{get_(default/test)_*} get each of those respective settings.
#' @seealso  \code{\link{ru_setup}},
#' \code{\link{get_default_pid}},
#' \code{\link{get_default_fid}},
#' \code{\link{get_default_url}},
#' \code{\link{get_default_un}},
#' \code{\link{get_default_pw}},
#' \code{\link{get_default_pp}},
#' \code{\link{get_default_tz}},
#' \code{\link{get_default_odkc_version}},
#' \code{\link{get_retries}},
#' \code{\link{get_test_pid}},
#' \code{\link{get_test_fid}},
#' \code{\link{get_test_fid_zip}},
#' \code{\link{get_test_fid_att}},
#' \code{\link{get_test_fid_gap}},
#' \code{\link{get_test_fid_wkt}},
#' \code{\link{get_test_url}},
#' \code{\link{get_test_un}},
#' \code{\link{get_test_pw}},
#' \code{\link{get_test_pp}},
#' \code{\link{get_test_odkc_version}},
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
    pp = Sys.getenv("ODKC_PP", ""),
    tz = Sys.getenv("RU_TIMEZONE", "UTC"),
    odkc_version = Sys.getenv("ODKC_VERSION", "2023.4.0"),
    retries = get_retries(),
    verbose = as.logical(Sys.getenv("RU_VERBOSE", FALSE)),
    test_pid = Sys.getenv("ODKC_TEST_PID", ""),
    test_fid = Sys.getenv("ODKC_TEST_FID", ""),
    test_fid_zip = Sys.getenv("ODKC_TEST_FID_ZIP", ""),
    test_fid_att = Sys.getenv("ODKC_TEST_FID_ATT", ""),
    test_fid_gap = Sys.getenv("ODKC_TEST_FID_GAP", ""),
    test_fid_wkt = Sys.getenv("ODKC_TEST_FID_WKT", ""),
    test_url = Sys.getenv("ODKC_TEST_URL", ""),
    test_un = Sys.getenv("ODKC_TEST_UN", ""),
    test_pw = Sys.getenv("ODKC_TEST_PW", ""),
    test_pp = Sys.getenv("ODKC_TEST_PP", ""),
    test_odkc_version = Sys.getenv("ODKC_TEST_VERSION", "2023.4.0")
  )
  structure(ops, class = "ru_settings")
}

#' @export
print.ru_settings <- function(x, ...) {
  cat("<ruODK settings>", sep = "\n")
  cat("  Default ODK Central Project ID:", x$pid, "\n")
  cat("  Default ODK Central Form ID:", x$fid, "\n")
  cat("  Default ODK Central URL:", x$url, "\n")
  cat("  Default ODK Central Username:", x$un, "\n")
  cat("  Default ODK Central Password: run ruODK::get_default_pw() to show \n")
  cat("  Default ODK Central Passphrase: run ruODK::get_default_pp() to show \n")
  cat("  Default Time Zone:", x$tz, "\n")
  cat("  Default ODK Central Version:", x$odkc_version, "\n")
  cat("  Default HTTP GET retries:", x$retries, "\n")
  cat("  Verbose messages:", x$verbose, "\n")
  cat("  Test ODK Central Project ID:", x$test_pid, "\n")
  cat("  Test ODK Central Form ID:", x$test_fid, "\n")
  cat("  Test ODK Central Form ID (ZIP tests):", x$test_fid_zip, "\n")
  cat("  Test ODK Central Form ID (Attachment tests):", x$test_fid_att, "\n")
  cat("  Test ODK Central Form ID (Parsing tests):", x$test_fid_gap, "\n")
  cat("  Test ODK Central Form ID (WKT tests):", x$test_fid_wkt, "\n")
  cat("  Test ODK Central URL:", x$test_url, "\n")
  cat("  Test ODK Central Username:", x$test_un, "\n")
  cat("  Test ODK Central Password: run ruODK::get_test_pw() to show \n")
  cat("  Test ODK Central Passphrase: run ruODK::get_test_pp() to show \n")
  cat("  Test ODK Central Version:", x$test_odkc_version, "\n")
}

#------------------------------------------------------------------------------#
# Helpers
#
#' Retrieve URL, project ID, and form ID from an ODK Central OData service URL.
#'
#' `r lifecycle::badge("stable")`
#'
#' @param svc (character) The OData service URL of a form as provided by the
#'   ODK Central form submissions tab.
# nolint start
#'   Example: "https://URL/v1/projects/PID/forms/FID.svc"
# nolint end
#' @export
#' @family ru_settings
#' @return A named list with three components (all of type character):
#' \itemize{
#'  \item \code{url} The ODK Central base URL.
#'  \item \code{pid} The project ID.
#'  \item\code{fid} The form ID.
#'  }
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
#' `r lifecycle::badge("stable")`
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
#'   e.g. "https://sandbox.central.getodk.org".
#'   This will override the ODK Central base URL from \code{svc}.
#' @param un An ODK Central username which is the email of a "web user" in the
#'   specified ODK Central instance \code{url} (optional, character).
#' @param pw The password for user \code{un} (optional, character).
#' @param pp The passphrase (optional, character) for an encrypted form.
#' @param odkc_version The ODK Central version as major/minor version, e.g. 1.1.
#' @param tz Global default time zone.
#'   `ruODK`'s time zone is determined in order of precedence:
#' \itemize{
#'   \item Function parameter:
#'     e.g. \code{\link{odata_submission_get}(tz = "Australia/Perth")}
#'   \item `ruODK` setting: \code{\link{ru_setup}(tz = "Australia/Perth")}
#'   \item Environment variable `RU_TIMEZONE` (e.g. set in `.Renviron`)
#'   \item UTC (GMT+00)
#'  }
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
#' @param test_fid_wkt (optional, character) The alphanumeric ID of an existing
#'   form in \code{test_pid}. This will override the form ID from
#'   \code{test_svc}.
#'   Provide the form ID of a form with geopoints, geotraces, and geoshapes.
#' @param test_url (optional, character) A valid ODK Central URL for testing.
#'   This will override the ODK Central base URL from \code{svc}.
#' @param test_un (optional, character) A valid ODK Central username (email)
#'   privileged to view the test project(s) at \code{test_url}.
#' @param test_pw (optional, character) The valid ODK Central password for
#'   \code{test_un}.
#' @param test_pp (optional, character) The valid passphrase to decrypt the
#'   data of encrypted project \code{test_pid} for download,
#'   only used for tests.
#' @param test_odkc_version The ODK Central test server's version as major/minor
#'   version, e.g. 1.1.
#' @template param-retries
#' @param verbose Global default for `ruODK` verbosity.
#'   `ruODK` verbosity is determined in order of precedence:
#'  \itemize{
#'     \item Function parameter:
#'       e.g. \code{\link{odata_submission_get}(verbose = TRUE)}
#'     \item `ruODK` setting: \code{\link{ru_setup}(verbose = TRUE)}
#'     \item Environment variable `RU_VERBOSE` (e.g. set in `.Renviron`)
#'     \item `FALSE`.
#'  }
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
#'   pp = "...",
#'   test_url = "https://sandbox.central.getodk.org",
#'   test_un = "me@email.com",
#'   test_pw = "...",
#'   test_pp = "...",
#'   test_pid = 14,
#'   test_fid = "build_Flora-Quadrat-0-2_1558575936",
#'   test_fid_zip = "build_Spotlighting-0-6_1558333698",
#'   test_fid_att = "build_Flora-Quadrat-0-1_1558330379",
#'   test_fid_gap = "build_Turtle-Track-or-Nest-1-0_1569907666",
#'   test_fid_wkt = "build_Locations_1589344221",
#'   retries = 3,
#'   verbose = TRUE
#' )
ru_setup <- function(svc = NULL,
                     pid = NULL,
                     fid = NULL,
                     url = NULL,
                     un = NULL,
                     pw = NULL,
                     pp = NULL,
                     tz = NULL,
                     odkc_version = NULL,
                     retries = NULL,
                     verbose = NULL,
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
                     test_odkc_version = NULL) {
  if (!is.null(svc)) {
    odata_components <- odata_svc_parse(svc)
    Sys.setenv("ODKC_PID" = odata_components$pid)
    Sys.setenv("ODKC_FID" = odata_components$fid)
    Sys.setenv("ODKC_URL" = odata_components$url)
  }

  # nolint start
  # The linter "undesirable_function_linter" would warn against changing global
  # state, which is exactly how ruODK persists settings and preferences.
  if (!is.null(pid)) Sys.setenv("ODKC_PID" = as.character(pid))
  if (!is.null(fid)) Sys.setenv("ODKC_FID" = fid)
  if (!is.null(url)) Sys.setenv("ODKC_URL" = url)
  if (!is.null(un)) Sys.setenv("ODKC_UN" = un)
  if (!is.null(pw)) Sys.setenv("ODKC_PW" = pw)
  if (!is.null(pp)) Sys.setenv("ODKC_PP" = pp)
  if (!is.null(tz)) Sys.setenv("RU_TIMEZONE" = tz)
  if (!is.null(odkc_version)) Sys.setenv("ODKC_VERSION" = odkc_version)
  if (!is.null(retries)) Sys.setenv("RU_RETRIES" = retries)
  if (!is.null(verbose)) Sys.setenv("RU_VERBOSE" = verbose)

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
  if (!is.null(test_fid_wkt)) Sys.setenv("ODKC_TEST_FID_WKT" = test_fid_wkt)
  if (!is.null(test_url)) Sys.setenv("ODKC_TEST_URL" = test_url)
  if (!is.null(test_un)) Sys.setenv("ODKC_TEST_UN" = test_un)
  if (!is.null(test_pw)) Sys.setenv("ODKC_TEST_PW" = test_pw)
  if (!is.null(test_pp)) Sys.setenv("ODKC_TEST_PP" = test_pp)
  if (!is.null(test_odkc_version)) {
    Sys.setenv("ODKC_TEST_VERSION" = test_odkc_version)
  }
  # nolint end

  if (get_ru_verbose()) {
    print(ru_settings())
  }
}

#------------------------------------------------------------------------------#
# Getters
#
#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_default_pid <- function() {
  x <- Sys.getenv("ODKC_PID")
  if (identical(x, "")) {
    ru_msg_warn("No default ODK Central Project ID set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_default_fid <- function() {
  x <- Sys.getenv("ODKC_FID")
  if (identical(x, "")) {
    ru_msg_warn("No default ODK Central Form ID set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_default_url <- function() {
  x <- Sys.getenv("ODKC_URL")
  if (identical(x, "")) {
    ru_msg_warn("No default ODK Central URL set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_default_un <- function() {
  x <- Sys.getenv("ODKC_UN")
  if (identical(x, "")) {
    ru_msg_warn("No default ODK Central username set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_default_pw <- function() {
  x <- Sys.getenv("ODKC_PW")
  if (identical(x, "")) {
    ru_msg_warn("No default ODK Central password set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_default_pp <- function() {
  x <- Sys.getenv("ODKC_PP")
  if (identical(x, "")) {
    ru_msg_warn("No default ODK Central passphrase set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_default_tz <- function() {
  x <- Sys.getenv("RU_TIMEZONE")
  if (identical(x, "")) {
    ru_msg_warn("No default timezone set, defaulting to 'UTC'. ru_setup()?")
    x <- "UTC"
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_url <- function() {
  x <- Sys.getenv("ODKC_TEST_URL")
  if (identical(x, "")) {
    ru_msg_warn("No test ODK Central URL set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_un <- function() {
  x <- Sys.getenv("ODKC_TEST_UN")
  if (identical(x, "")) {
    ru_msg_warn("No test ODK Central username set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_pw <- function() {
  x <- Sys.getenv("ODKC_TEST_PW")
  if (identical(x, "")) {
    ru_msg_warn("No test ODK Central password set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_pid <- function() {
  x <- Sys.getenv("ODKC_TEST_PID")
  if (identical(x, "")) {
    ru_msg_warn("No test ODK Central project ID set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_fid <- function() {
  x <- Sys.getenv("ODKC_TEST_FID")
  if (identical(x, "")) {
    ru_msg_warn("No test ODK Central form ID set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_fid_zip <- function() {
  x <- Sys.getenv("ODKC_TEST_FID_ZIP")
  if (identical(x, "")) {
    ru_msg_warn("No test ODK Central ZIP form ID set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_fid_att <- function() {
  x <- Sys.getenv("ODKC_TEST_FID_ATT")
  if (identical(x, "")) {
    ru_msg_warn("No test ODK Central ATT form ID set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_fid_gap <- function() {
  x <- Sys.getenv("ODKC_TEST_FID_GAP")
  if (identical(x, "")) {
    ru_msg_warn("No test ODK Central GAP form ID set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_fid_wkt <- function() {
  x <- Sys.getenv("ODKC_TEST_FID_WKT")
  if (identical(x, "")) {
    ru_msg_warn("No test ODK Central WKT form ID set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_pp <- function() {
  x <- Sys.getenv("ODKC_TEST_PP")
  if (identical(x, "")) {
    ru_msg_warn("No test ODK Central passphrase set. ru_setup()?")
  }
  x
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_ru_verbose <- function() {
  Sys.getenv("RU_VERBOSE", unset = FALSE) %>% as.logical()
}


#' Parse a given ODK Central version string or number into a `semver`.
#'
#' `r lifecycle::badge("stable")`
#'
#' Past versions of ruODK advised to set ODKC_VERSION to a floating point number
#' indicating major and minor versions, e.g. `ODKC_VERSION=0.7` or
#' `ODKC_VERSION=1.5`.
#'
#' ODK Central has since switched to semantic versioning, e.g.
#' `ODKC_VERSION=ODKC_VERSION=`.
#'
#' To preserve backwards compatibility, ruODK handles both formats gracefully,
#' but emits a helpful warning to update the version string if the older format
#' is detected, or the version string is missing the minor or patch version.
#'
#' @param v A string (e.g. "ODKC_VERSION=") or number (e.g. 0.8, 1.5) of a
#'   complete or partial semver, or a semver of class "svlist".
#' @param env_var A string indicating which environment variable was targeted.
#'   This is used in the warning to advise which environment variable to update.
#'   If set to an empty string, the warning message is suppressed.
#'   Default: "ODKC_VERSION".
#' @return semver::svlist The version as semver of major, minor, and patch.
#'
#' @export
#' @import semver
#' @family ru_settings
#' @examples
#' parse_odkc_version("1.2.3")
#'
#' # Warn: too short
#' parse_odkc_version("1")
#' parse_odkc_version("1.2")
#'
#' # Warn: too long
#' parse_odkc_version("1.2.3.4")
#'
#' # Warn: otherwise invalid
#' parse_odkc_version("1.2.")
#' parse_odkc_version(".2.3")
#'
parse_odkc_version <- function(v, env_var = "ODKC_VERSION") {
  # If the given version is already a semver, return it as is
  # This may fail when run in testthat, where semver svlists are somehow
  # transformed to character and then not recognised as pointers here.
  if (rlang::inherits_any(v, c("svlist", "svptr"))) {
    return(v)
  }

  # If not, convert to string and proceed
  v_string <- as.character(v)

  v_invalid <- FALSE
  emit_warning <- env_var != ""

  # The version string should start and end with a digit
  if (!stringr::str_detect(v_string, "^[0-9]")) {
    v_string <- paste0("0", v_string)
    v_invalid <- TRUE
  }
  if (!stringr::str_detect(v_string, "[0-9]$")) {
    v_string <- paste0(v_string, "0")
    v_invalid <- TRUE
  }

  # The version string should have two decimal points
  decimals_found <- stringr::str_count(v_string, pattern = "\\.")
  decimals_missing <- max(2 - decimals_found, 0)

  # Create repaired version
  v_repaired <- v_string

  # If the version string is missing components (minor, patch), add ".0"
  if (decimals_found < 2) {
    for (x in 1:decimals_missing) {
      v_repaired <- stringr::str_c(v_repaired, ".0")
    }
    v_invalid <- TRUE
  }

  # If the version string has too many components, discard them
  if (decimals_found > 2) {
    v_repaired <- stringr::str_replace(
      v_string,
      "^(([^.]*\\.){2}[^.]*)\\..*$", "\\1"
    )
    v_invalid <- TRUE
  }

  # If the version needed repair and unless silenced, emit helpful advice
  if (v_invalid == TRUE && emit_warning == TRUE) {
    ru_msg_warn(glue::glue(
      "Please update your environment variable {env_var} ",
      "from \"{v_string}\" to \"{v_repaired}\"."
    ))
  }

  # Parse what is now a valid semver string to semver
  v_semver <- semver::parse_version(v_repaired)
  v_semver
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_default_odkc_version <- function() {
  Sys.getenv("ODKC_VERSION", unset = "2023.5.1")
}

#' Show whether a given semver is greater than a baseline version.
#'
#' @param sv The semver to compare as character
#'    ("2023.5.1", "1.5.0", "1.5"), or numeric (1.5).
#'    The value is always parsed with `semver::parse_semver()`.
#'    Default: get_default_odkc_version().
#' @param to The semver to compare to as string. Although semver can parse
#'    complete version strings, `to` is still parsed by `parse_odkc_version()`
#'    to ensure it is complete with major, minor, and patch version components.
#' @returns A boolean indicating whether the given semver `sv` is greater than
#'    the baseline semver `to`.
#' @family ru_settings
#' @export
#' @examples
#' get_default_odkc_version() |> semver_gt("0.8.0")
#' "2024.1.1" |> semver_gt("2024.1.0")
#' "2024.1.1" |> semver_gt("2024.1.1")
#' "2024.1.1" |> semver_gt("2024.1.2")
semver_gt <- function(sv = get_default_odkc_version(), to = "1.5.0") {
  base_version <- parse_odkc_version(sv, env_var = "")
  to_version <- parse_odkc_version(to, env_var = "")
  base_version[[1]] > to_version[[1]]
}


#' Show whether a given semver is lesser than a baseline version.
#'
#' @param sv The semver to compare as character
#'    ("2023.5.1", "1.5.0", "1.5"), or numeric (1.5).
#'    The value is always parsed with `semver::parse_semver()`.
#'    Default: get_default_odkc_version().
#' @param to The semver to compare to as string. Although semver can parse
#'    complete version strings, `to` is still parsed by `parse_odkc_version()`
#'    to ensure it is complete with major, minor, and patch version components.
#' @returns A boolean indicating whether the given semver `sv` is greater than
#'    the baseline semver `to`.
#' @family ru_settings
#' @export
#' @examples
#' get_default_odkc_version() |> semver_lt("0.8.0")
#' "2024.1.1" |> semver_lt("2024.1.0")
#' "2024.1.1" |> semver_lt("2024.1.1")
#' "2024.1.1" |> semver_lt("2024.1.2")
semver_lt <- function(sv = get_default_odkc_version(), to = "1.5.0") {
  base_version <- parse_odkc_version(sv, env_var = "")
  to_version <- parse_odkc_version(to, env_var = "")
  base_version[[1]] < to_version[[1]]
}


#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_test_odkc_version <- function() {
  Sys.getenv("ODKC_TEST_VERSION", unset = "2023.5.1")
}

#' `r lifecycle::badge("stable")`
#' @export
#' @rdname ru_settings
get_retries <- function() {
  suppressWarnings(as.integer(Sys.getenv("RU_RETRIES", unset = 3))) %>%
    tidyr::replace_na(3L)
}

#' Abort on missing ODK Central credentials (url, username, password).
#'
#' `r lifecycle::badge("stable")`
#'
#' @param url A URL (character)
#' @param un A username (character)
#' @param pw A password (character)
#' @param pid A project ID (numeric, optional)
#' @param fid A form ID (character, optional)
#' @param did An Entity List (dataset) name (character, optional)
#' @param eid An Entity UUID (character, optional)
#' @details This is a helper function to pat down \code{\link{ruODK}} functions
#'   for missing credentials and stop with a loud but informative yell.
#' @param iid A submission instance ID (character, optional)
#' @family ru_settings
#' @keywords internal
#' @examples
#' testthat::expect_error(yell_if_missing("", "username", "password"))
#' testthat::expect_error(yell_if_missing("url", "", "password"))
#' testthat::expect_error(yell_if_missing("url", "username", ""))
#' testthat::expect_error(yell_if_missing(NULL, "", ""))
#' testthat::expect_error(yell_if_missing("", "", ""))
#' testthat::expect_error(yell_if_missing("", "", "", ""))
#' testthat::expect_error(yell_if_missing("", "", "", "", ""))
#' testthat::expect_error(yell_if_missing("", "", "", "", "", ""))
#' testthat::expect_error(yell_if_missing("", "", "", "", "", "", ""))
#' testthat::expect_error(yell_if_missing("", "", "", "", "", "", "", ""))
yell_if_missing <- function(
    url, un, pw, pid = NULL, fid = NULL, iid = NULL, did = NULL, eid = NULL) {
  if (is.null(url) || identical(url, "")) {
    ru_msg_abort("Missing ODK Central URL. ru_setup()?")
  }
  if (is.null(un) || identical(un, "")) {
    ru_msg_abort("Missing ODK Central username. ru_setup()?")
  }
  if (is.null(pw) || identical(pw, "")) {
    ru_msg_abort("Missing ODK Central password. ru_setup()?")
  }
  if (!is.null(pid) && identical(pid, "")) {
    ru_msg_abort("Missing ODK Central project ID. ru_setup()?")
  }
  if (!is.null(fid) && identical(fid, "")) {
    ru_msg_abort("Missing ODK Central form ID. ru_setup()?")
  }
  if (!is.null(iid) && identical(iid, "")) {
    ru_msg_abort("Missing ODK Central submission instance ID.")
  }
  if (!is.null(did) && identical(did, "")) {
    ru_msg_abort("Missing ODK Central Entity List (dataset) name.")
  }
  if (!is.null(eid) && identical(eid, "")) {
    ru_msg_abort("Missing ODK Central Entity UUID.")
  }
}

#' Warn about failed web requests and give helpful troubleshooting tips.
#'
#' `r lifecycle::badge("stable")`
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
#' @keywords internal
yell_if_error <- function(response, url, un, pw, pid = NULL, fid = NULL) {
  response %>%
    httr::stop_for_status(
      task = glue::glue(
        "get desired response from server {url} as user \"{un}\".\n\n",
        "Troubleshooting tips:\n",
        "* Is the server online at {url}? Is the internet flaky? Retry!\n",
        "* Check ruODK::ru_settings() - credentials and defaults correct?\n",
        "* Run ru_setup() with working credentials and defaults.\n",
        '* Read the vignette("setup", package = "ruODK") how to set up ruODK.\n',
        "* If an encrypted form returns HTTP 500: Wrong passphrase?",
      )
    )
}

# usethis::use_test("ru_setup")  # nolint
