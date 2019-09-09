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
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @template param-url
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
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-2_1558575936.svc",
#'   un = "me@email.com",
#'   pw = "..."
#' )
#'
#' sl <- submission_list()
#'
#' al <- attachment_list(sl$instance_id[[1]])
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
attachment_list <- function(iid,
                            pid = get_default_pid(),
                            fid = get_default_fid(),
                            url = get_default_url(),
                            un = get_default_un(),
                            pw = get_default_pw()) {
  . <- NULL
  yell_if_missing(url, un, pw)
  glue::glue(
    "{url}/v1/projects/{pid}/forms/{fid}/submissions/{iid}/attachments"
  ) %>%
    httr::GET(
      httr::add_headers("Accept" = "application/json"),
      httr::authenticate(un, pw)
    ) %>%
    yell_if_error(., url, un, pw) %>%
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
