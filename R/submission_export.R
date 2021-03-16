#' Export all form submissions including repeats and attachments to CSV.
#'
#' To export all the Submission data associated with a Form, just add .csv.zip
#' to the end of the listing URL. The response will be a zip file containing one
#' or more CSV files, as well as all multimedia attachments associated with the
#' included Submissions.
#'
#' The file will be downloaded to the project root unless specified otherwise
#' (via `local_dir`). Subsequently, the zip file can be extracted.
#' Attachment filenames (e.g. "12345.jpg") should be prepended with `media`
#' (resulting in e.g. `media/12345.jpg`) in order to represent the relative
#' path to the actual attachment file (as extracted from the zip file).
#'
#' This function downloads all submissions and attachments in one go.
#' For incremental download of a subset of submissions, use
#' \code{\link{submission_list}},
#' choose the submissions of interest (e.g. by submission date), and use their
#' uuids to download them one by one via \code{\link{submission_get}}.
#' Download attachments as listed for each submission
#' (\code{\link{attachment_list}}).
#'
#' If the submissions are encrypted
#'
#' `r lifecycle::badge("stable")`
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
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/exporting-form-submissions-to-csv}
# nolint end
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = "....svc",
#'   un = "me@email.com",
#'   pw = "...",
#'   pp = "..."
#' )
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
                              pp = NULL,
                              retries = get_retries(),
                              odkc_version = get_default_odkc_version(),
                              verbose = get_ru_verbose()) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  url_ext <- ".csv.zip"
  file_ext <- ".zip"

  if (odkc_version >= 1.1) {
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
      ru_msg_noop()
    }
    if (repeats == FALSE) {
      "Omitting repeat data requires ODK Central v1.1 or higher" %>%
      ru_msg_noop()
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
      if (verbose == TRUE) {
        "Overwriting previous download: \"{pth}\"" %>%
          glue::glue() %>% ru_msg_success()
      }
    } else {
      if (verbose == TRUE) {
        "Keeping previous download: \"{pth}\"" %>%
          glue::glue() %>% ru_msg_noop()
      }
      return(pth)
    }
  } else {
    if (verbose == TRUE) {
      "Downloading submissions from {url_pth} to {pth}" %>%
        glue::glue() %>% ru_msg_success()
    }
  }

  # List encryption keys
  encryption_keys <- httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/submissions/keys"
      )
    ),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.)

  body <- NULL
  # Create body containing encryption key and passphrase
  # associated with the request
  if (length(encryption_keys) > 0) {
    body <- list()
    var <- toString(encryption_keys[[1]]$id)
    body[[var]] <- pp

    if (verbose == TRUE) {
      "Found multiple encryption keys for form {fid}, using the first key." %>%
        glue::glue() %>% ru_msg_info()
    }
  }

  # Export form submissions to CSV via POST
  httr::RETRY(
    "POST",
    httr::modify_url(url, path = url_pth),
    body = body,
    encode = "json",
    httr::authenticate(un, pw),
    httr::write_disk(pth, overwrite = overwrite),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.)
  pth
}

# usethis::use_test("submission_export") # nolint
