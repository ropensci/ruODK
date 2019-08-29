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
#'   get_test_pid(),
#'   get_test_fid(),
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#' sl %>% knitr::kable(.)
#'
#' fl <- form_list(
#'   get_test_pid(),
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
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
#'   filter(fid == get_test_fid()) %>%
#'   magrittr::extract2("submissions") %>%
#'   as.numeric()
#' nrow(sl) == form_list_nsub
#' # > TRUE
#' }
submission_list <- function(pid,
                            fid,
                            url = get_default_url(),
                            un = get_default_un(),
                            pw = get_default_pw()) {
  . <- NULL
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}/submissions") %>%
    httr::GET(
      httr::add_headers(
        "Accept" = "application/json",
        "X-Extended-Metadata" = "true"
      ),
      httr::authenticate(un, pw)
    ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    {
      tibble::tibble(
        instance_id = purrr::map_chr(., "instanceId"),
        submitter_id = map_int_hack(., c("submitter", "id")),
        device_id = map_chr_hack(., "deviceId"),
        created_at = map_dttm_hack(., "createdAt"),
        updated_at = map_dttm_hack(., "updatedAt")
      )
    }
}

# Tests
# usethis::edit_file("tests/testthat/test-submission_list.R")
