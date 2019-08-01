#' Export all form submissions to CSV.
#'
#' To export all the Submission data associated with a Form, just add .csv.zip
#' to the end of the listing URL. The response will be a zip file containing one
#' or more CSV files, as well as all multimedia attachments associated with the
#' included Submissions.
#'
#' The file will be downloaded to the project root unless specified otherwise
#' (via `local_dir`). Subsequently, the zip file can be extracted.
#' Attachment filenames (e.g. "12345.jpg") should be prepended with `media`
#' (resulting in e.g. `media\12345.jpg`) in order to represent the relative
#' path to the actual attachment file (as extracted from the zip file).
#'
#' This function downloads all submissions and attachments in one go.
#' For incremental download of a subset of submissions, use `submission_list`,
#' choose the submissions of interest (e.g. by submission date), and use their
#' uuids to download them one by one via `submission_get`. Download attachments
#' as listed for each submission (`attachment_list`).
#'
#' @template param-pid
#' @template param-fid
#' @param local_dir The local folder to save the downloaded files to,
#'                  default: `here::here()`.
#' @param overwrite Whether to overwrite previously downloaded zip files,
#'                 default: FALSE
#' @template param-auth
#' @template param-verbose
#' @return The absolute path to the zip file named "`fid`.zip"
#'         containing submissions as CSV,
#'         plus separate CSVs for any repeating groups,
#'         plus any attachments in a subfolder `media`.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/exporting-form-submissions-to-csv}
#' @family restful-api
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' se <- submission_export(1, "build_xformsId")
#'
#' # With explicit credentials, see tests
#'
#' t <- tempdir()
#'
#' se <- submission_export(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   local_dir = t,
#'   overwrite = FALSE,
#'   verbose = TRUE,
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#'
#' # Unzip and inspect the loot
#'
#' t <- tempdir()
#' f <- unzip(se, exdir = t)
#' fs::dir_ls(t)
#' fid <- Sys.getenv("ODKC_TEST_FID")
#' sub <- fs::path(t, glue::glue("{fid}.csv")) %>% readr::read_csv()
#' sub %>% knitr::kable(.)
#' # Cleanup
#' fs::dir_delete(t)
#' }
submission_export <- function(pid,
                              fid,
                              local_dir = here::here(),
                              overwrite = TRUE,
                              url = Sys.getenv("ODKC_URL"),
                              un = Sys.getenv("ODKC_UN"),
                              pw = Sys.getenv("ODKC_PW"),
                              verbose = FALSE) {
  . <- NULL
  pth <- fs::path(local_dir, glue::glue("{fid}.zip"))

  if (verbose == TRUE) {
    if (fs::file_exists(pth)) {
      if (overwrite == TRUE) {
        message(glue::glue("Overwriting previous download: {pth}\n"))
      } else {
        message(glue::glue("Keeping previous download: {pth}\n"))
        return(pth)
      }
    } else {
      message(glue::glue("Downloading submissions to: {pth}\n"))
    }
  }

  glue::glue("{url}/v1/projects/{pid}/forms/{fid}/submissions.csv.zip") %>%
    httr::GET(
      httr::authenticate(un, pw),
      httr::write_disk(pth, overwrite = overwrite)
    ) %>%
    httr::stop_for_status() %>%
    httr::content(.)
  pth
}
