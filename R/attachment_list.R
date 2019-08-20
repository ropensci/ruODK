#' List all submissions of one form.
#'
#'
#' When a Submission is created, either over the OpenRosa or the REST interface,
#' its XML data is analysed to determine which file attachments it references:
#' these may be photos or video taken as part of the survey, or an audit/timing
#' log, among other things. Each reference is an expected attachment, and these
#' expectations are recorded permanently alongside the Submission. With this
#' subresource, you can list the expected attachments, see whether the server
#' actually has a copy or not, and download, upload, re-upload, or clear binary
#' data for any particular attachment.
#'
#' You can retrieve the list of expected Submission attachments at this route,
#' along with a boolean flag indicating whether the server actually has a copy
#' of the expected file or not. If the server has a file, you can then append
#' its filename to the request URL to download only that file (see below).
#' @template param-pid
#' @template param-fid
#' @template param-iid
#' @template param-auth
#' @return A tibble containing some high-level details of the submission
#'         attachments.
#'         One row per submission attachment, columns are submission attributes:
#'
#'         * name: The attachment filename, e.g. 12345.jpg
#'         * exists: Whether the attachment for that submission exists on the
#'           server.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/attachments/listing-expected-submission-attachments}
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/'-form-attachments/listing-expected-form-attachments}
#' @family restful-api
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' s_default <- submission_list(1, "build_xformsId", "uuid:...")
#'
#' # With explicit credentials, see tests
#' sl <- submission_list(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#'
#' al <- attachment_list(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   sl$instance_id[[1]],
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#' al %>% knitr::kable(.)
#'
#' # attachment_list returns a tibble
#' class(al)
#' # > c("tbl_df", "tbl", "data.frame")
#'
#' # Submission attributes are the tibble's columns
#' names(al)
#' # > "name" "exists"
#' }
attachment_list <- function(pid,
                            fid,
                            iid,
                            url = Sys.getenv("ODKC_URL"),
                            un = Sys.getenv("ODKC_UN"),
                            pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue(
    "{url}/v1/projects/{pid}/forms/{fid}/submissions/{iid}/attachments"
  ) %>%
    httr::GET(
      httr::add_headers("Accept" = "application/json"),
      httr::authenticate(un, pw)
    ) %>%
    httr::stop_for_status() %>%
    httr::content(.) %>%
    {
      tibble::tibble(
        name = purrr::map_chr(., "name"),
        exists = purrr::map_lgl(., "exists")
      )
    }
}

# Tests
# usethis::edit_file("tests/testthat/test-attachment_list.R")
