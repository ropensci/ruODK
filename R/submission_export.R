#' Export all form submissions including repeats and attachments to CSV.
#'
#' `r lifecycle::badge("maturing")`
#'
#' This function exports all the Submission data associated with a Form as one
#' zip file containing one or more CSV files, as well as all multimedia
#' attachments associated with the included Submissions.
#'
#' For an incremental download of a subset of submissions, use
#' \code{\link{submission_list}} or \code{\link{odata_submission_get}} with
#' filter queries.
#'
#' ### Contents
#' The inclusion of subtables (from repeating form groups) can be toggled
#' through `repeats`, whereas the inclusion of media attachments can be toggled
#' through `media`.
#'
#' ### Download location
#' The file will be downloaded to the project root unless specified otherwise
#' (via `local_dir`). Subsequently, the zip file can be extracted.
#' Attachment filenames (e.g. "12345.jpg") should be prepended with `media`
#' (resulting in e.g. `media/12345.jpg`) in order to represent the relative
#' path to the actual attachment file (as extracted from the zip file).
#'
#' ### Encryption
#' ODK Central supports two modes of encryption - learn about them
#' [here](https://docs.getodk.org/central-api-encryption/).
#' `ruODK` supports project managed encryption, however the support is limited
#' to exactly one encryption key. The supplied passphrase will be used against
#' the first returned encryption key. Remaining encryption keys are ignored by
#' `ruODK`.
#'
#' If an incorrect passphrase is given, the request is terminated immediately.
#' It has been reported that multiple requests with incorrect passphrases
#' can crash ODK Central.
#'
#' @param local_dir The local folder to save the downloaded files to,
#'                  default: \code{here::here}.
#' @param overwrite Whether to overwrite previously downloaded zip files,
#'                 default: FALSE
#' @param media Whether to include media attachments, default: TRUE.
#'   This feature only has effect on ODK Central v1.1 and higher.
#'   Setting this feature to FALSE with an odkc_version < 1.1 and will display a
#'   verbose noop message, but still return all media attachments.
#' @param repeats Whether to include repeat data (if TRUE), or whether
#'   to return the root table only (FALSE). Default: TRUE.
#'   Requesting `repeats=FALSE` will also omit any media, and override the
#'   parameter `media`.
#'   Setting this feature to FALSE with an odkc_version < 1.1 and will display a
#'   verbose noop message, but still include all repeat data.
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-pp
#' @template param-retries
#' @template param-odkcv
#' @template param-verbose
#' @return The absolute path to the exported ZIP file named after the form ID.
#'         The exported ZIP file will have the extension `.zip` unless only the
#'         root table was requested (with `repeats=FALSE`), in which case the
#'         exported file will have the extension `.csv`.
#'         In contrast to ODK Central, which exports to `submissions.csv(.zip)`,
#'         the exported ZIP file is named after
#'         the form to avoid accidentally overwriting the ZIP export from
#'         another form.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#exporting-form-submissions-to-csv}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' se <- submission_export()
#'
#' # Unzip and inspect the loot
#' t <- tempdir()
#' f <- unzip(se, exdir = t)
#' fs::dir_ls(t)
#' fid <- get_test_fid()
#' sub <- fs::path(t, glue::glue("{fid}.csv")) %>% readr::read_csv()
#' sub %>% knitr::kable(.)
#' }
submission_export <- function(local_dir = here::here(),
                              overwrite = TRUE,
                              media = TRUE,
                              repeats = TRUE,
                              pid = get_default_pid(),
                              fid = get_default_fid(),
                              url = get_default_url(),
                              un = get_default_un(),
                              pw = get_default_pw(),
                              pp = get_default_pp(),
                              retries = get_retries(),
                              odkc_version = get_default_odkc_version(),
                              verbose = get_ru_verbose()) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  url_ext <- ".csv.zip"
  file_ext <- ".zip"

  if (semver_gt(odkc_version, "1.0.0")) {
    # odkc_version >= 1.1
    if (media == FALSE) {
      url_ext <- ".csv.zip?attachments=false"
    }
    if (repeats == FALSE) {
      url_ext <- ".csv"
      file_ext <- ".csv"
    }
  } else {
    if (media == FALSE) {
      "Omitting media attachments requires ODK Central v1.1 or higher" %>%
        ru_msg_noop(verbose = verbose)
    }
    if (repeats == FALSE) {
      "Omitting repeat data requires ODK Central v1.1 or higher" %>%
        ru_msg_noop(verbose = verbose)
    }
  }

  url_pth <- glue::glue(
    "v1/projects/{pid}/forms/",
    "{URLencode(fid, reserved = TRUE)}/submissions{url_ext}"
  )

  pth <- fs::path(
    local_dir,
    glue::glue("{URLencode(fid, reserved = TRUE)}{file_ext}")
  )

  if (fs::file_exists(pth)) {
    if (overwrite == TRUE) {
      "Overwriting previous download: \"{pth}\"" %>%
        glue::glue() %>%
        ru_msg_success(verbose = verbose)
    } else {
      "Keeping previous download: \"{pth}\"" %>%
        glue::glue() %>%
        ru_msg_success(verbose = verbose)

      return(pth)
    }
  } else {
    "Downloading submissions from {url_pth} to {pth}" %>%
      glue::glue() %>%
      ru_msg_success(verbose = verbose)
  }

  # List encryption keys
  encryption_keys <- encryption_key_list(
    url = url,
    un = un,
    pw = pw,
    pid = pid,
    fid = fid,
    retries = retries
  )

  body <- NULL

  if (nrow(encryption_keys) > 0) {
    body <- list()
    var <- toString(encryption_keys$id[[1]])
    body[[var]] <- pp
    glue::glue(
      "Found {nrow(encryption_keys)} encryption keys for form {fid},",
      " using the first key with the supplied passphrase."
    ) %>%
      ru_msg_info(verbose = verbose)
  }

  # Export form submissions to CSV via POST
  httr::RETRY(
    "POST",
    httr::modify_url(url, path = url_pth),
    body = body,
    encode = "json",
    httr::authenticate(un, pw),
    httr::write_disk(pth, overwrite = overwrite),
    times = retries,
    quiet = verbose,
    # See discussion at https://github.com/ropensci/ruODK/issues/30
    # Sending multiple RETRY requests with incorrect passphrase can exceed
    # server memory limits.
    # Terminate retries immediately if ODK Central returns HTTP status 500
    # on wrong passphrases.
    terminate_on = c(500)
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.)
  pth
}

# usethis::use_test("submission_export") # nolint
