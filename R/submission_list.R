#' List all submissions of one form.
#'
#' @template param-pid
#' @template param-fid
#' @template param-auth
#' @return A tibble containing some high-level details of the form submissions.
#'         One row per submission, columns are submission attributes:
#'
#'         * instance_id: uuid, string. The unique ID for each submission.
#'         * submitter_id: user ID, integer.
#'         * device_id: Android device ID, string
#'         * created_at: time of submission upload, dttm
#'         * updated_at: time of submission update on server, dttm or NA
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/listing-all-submissions-on-a-form}
#' @family restful-api
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' sl_defaults <- submission_list(1, "build_xformsId")
#'
#' # With explicit credentials, see tests
#' sl <- submission_list(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#' sl %>% knitr::kable(.)
#'
#' sl <- submission_list(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#' fl <- form_list(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#'
#' # submission_list returns a tibble
#' class(sl)
#' # > c("tbl_df", "tbl", "data.frame")
#'
#' # Submission attributes are the tibble's columns
#' names(sl)
#' # > "instance_id" "submitter_id" "device_id" "created_at" "updated_at"
#'
#' # Number of submissions (rows) is same as advertised in form_list
#' form_list_nsub <- fl %>%
#'   filter(fid == Sys.getenv("ODKC_TEST_FID")) %>%
#'   magrittr::extract2("submissions") %>%
#'   as.numeric()
#' nrow(sl) <- form_list_nsub
#' # > TRUE
#' }
submission_list <- function(pid,
                            fid,
                            url = Sys.getenv("ODKC_URL"),
                            un = Sys.getenv("ODKC_UN"),
                            pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue(
    "{url}/v1/projects/{pid}/forms/{fid}/submissions"
  ) %>%
    httr::GET(
      httr::add_headers("Accept" = "application/json"),
      httr::authenticate(un, pw)
    ) %>%
    httr::stop_for_status() %>%
    httr::content(.) %>%
    {
      tibble::tibble(
        instance_id = purrr::map_chr(., "instanceId"),
        submitter_id = purrr::map_int(., "submitter"),
        device_id = map_chr_hack(., "deviceId"),
        created_at = map_dttm_hack(., "createdAt"),
        updated_at = map_dttm_hack(., "updatedAt")
      )
    }
}
