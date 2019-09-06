#' Download one submission.
#'
#' @template param-pid
#' @template param-fid
#' @template param-iid
#' @template param-auth
#' @return A nested list of submission data.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/retrieving-submission-xml}
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' sub <- submission_get(1, "build_xformsId", "uuid:...")
#'
#' # With explicit credentials, see tests
#' sl <- submission_list(
#'   get_test_pid(),
#'   get_test_fid(),
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' sub <- submission_get(
#'   get_test_pid(),
#'   get_test_fid(),
#'   sl$instance_id[[1]],
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#' listviewer::jsonedit(sub)
#'
#' # The details for one submission depend on the form fields
#' length(sub)
#' # > 11
#'
#' # The items are the field names. Repeated groups have the same name.
#' names(sub)
#' # > "meta"                     "encounter_start_datetime" "reporter"
#' # > "device_id"                "location"                 "habitat"
#' # > "vegetation_structure"     "perimeter"                "taxon_encounter"
#' # > "taxon_encounter"          "encounter_end_datetime"
#' }
submission_get <- function(pid,
                           fid,
                           iid,
                           url = get_default_url(),
                           un = get_default_un(),
                           pw = get_default_pw()) {
  . <- NULL
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}/submissions/{iid}.xml") %>%
    httr::GET(httr::authenticate(un, pw)) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    xml2::as_list(.) %>%
    magrittr::extract2("data")
}

# Tests
# usethis::edit_file("tests/testthat/test-submission_get.R")
