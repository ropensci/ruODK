#' Download one submission.
#'
#' \lifecycle{stable}
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @return A nested list of submission data.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/retrieving-submission-xml}
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = paste0(
#'     "https://sandbox.central.opendatakit.org/v1/projects/14/",
#'     "forms/build_Flora-Quadrat-0-2_1558575936.svc"
#'   ),
#'   un = "me@email.com",
#'   pw = "..."
#' )
#'
#' # With explicit credentials, see tests
#' sl <- submission_list()
#'
#' sub <- submission_get(sl$instance_id[[1]])
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
submission_get <- function(iid,
                           pid = get_default_pid(),
                           fid = get_default_fid(),
                           url = get_default_url(),
                           un = get_default_un(),
                           pw = get_default_pw()) {
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
