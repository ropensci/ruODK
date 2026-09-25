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
#' The splitting of select multiple answers into one boolean column per option
#' can be toggled through `split_select_multiples`.
#' The group path prefixes of field header names can be toggled through
#' `group_paths`.
#' The exported rows can be restricted through `filter`.
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
#' @param deleted_fields Whether to restore all fields previously deleted
#'   from this form for this export (TRUE).
#'   All known fields and data for those fields will be merged and exported.
#'   default: FALSE
#' @param split_select_multiples Whether to split select multiple answers
#'   into columns (TRUE).
#'   If TRUE, a boolean column is created for every known select multiple
#'   option in the export.
#'   The option name is in the field header, and a 0 or a 1 is present in each
#'   cell indicating whether that option was checked for that row.
#'   Default: FALSE.
#' @param group_paths Whether to keep group path prefixes in field header
#'   names (TRUE, e.g. meta-instanceID) or remove them (FALSE, e.g.
#'   instanceID).
#'   Default: TRUE.
#' @param filter (str) An OData-style `$filter` query to filter the
#'   Submissions in the export.
#'   Only a subset of the `$filter` features is available.
#'   Default: NULL (no filtering, all Submissions exported).
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
submission_export <- function(
  local_dir = here::here(),
  overwrite = TRUE,
  media = TRUE,
  repeats = TRUE,
  deleted_fields = FALSE,
  split_select_multiples = FALSE,
  group_paths = TRUE,
  filter = NULL,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  pp = get_default_pp(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  verbose = get_ru_verbose()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (
    !is.null(filter) &&
      (!is.character(filter) || length(filter) != 1L || is.na(filter))
  ) {
    ru_msg_abort("filter must be a single query string.")
  }

  url_ext <- ".csv.zip"
  file_ext <- ".zip"
  query <- NULL

  if (semver_gt(odkc_version, "1.0.0")) {
    # odkc_version >= 1.1
    if (media == FALSE) {
      url_ext <- ".csv.zip"
      query <- list("attachments" = "false")
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

  if (deleted_fields == TRUE) {
    query <- c(query, list("deletedFields" = "true"))
  } else {
    query <- c(query, list("deletedFields" = "false"))
  }

  if (split_select_multiples == TRUE) {
    query <- c(query, list("splitSelectMultiples" = "true"))
  } else {
    query <- c(query, list("splitSelectMultiples" = "false"))
  }

  if (group_paths == TRUE) {
    query <- c(query, list("groupPaths" = "true"))
  } else {
    query <- c(query, list("groupPaths" = "false"))
  }

  if (!is.null(filter)) {
    query <- c(query, list("$filter" = filter))
  }

  url_pth <- glue::glue(
    "v1/projects/{pid}/forms/",
    "{URLencode(fid, reserved = TRUE)}/submissions{url_ext}"
  )

  if (!fs::dir_exists(local_dir)) {
    fs::dir_create(local_dir)
  }

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
  # See discussion at https://github.com/ropensci/ruODK/issues/30
  # Sending multiple RETRY requests with incorrect passphrase can exceed
  # server memory limits.
  # Terminate retries immediately if ODK Central returns HTTP status 500
  # on wrong passphrases.
  ru_http_request(
    "POST",
    url,
    path = url_pth,
    query = query,
    accept = NULL,
    un = un,
    pw = pw,
    body = body,
    encode = "json",
    dest = pth,
    overwrite = overwrite,
    terminate_on = c(500),
    retries = retries
  ) %>%
    yell_if_error(., url, un, pw)
  pth
}

# usethis::use_test("submission_export") # nolint
