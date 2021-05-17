#' Download one submission.
#'
#' This function is the workhorse for the vectorised function submission_get,
#' which gets all submissions for a list of submission IDs.
#'
#' Note this function returns a nested list containing any repeating subgroups.
#' As the presence and length of repeating subgroups is non-deterministic and
#' entirely depends on the completeness of the submission data, we cannot
#' rectangle them any further here. Rectangling requires knowledge of the form
#' schema and the completeness of submission data.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A nested list of submission data.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/retrieving-submission-xml}
# nolint end
#' @family utilities
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' # With explicit credentials, see tests
#' sl <- submission_list()
#'
#' sub <- get_one_submission(sl$instance_id[[1]])
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
get_one_submission <- function(iid,
                               pid = get_default_pid(),
                               fid = get_default_fid(),
                               url = get_default_url(),
                               un = get_default_un(),
                               pw = get_default_pw(),
                               retries = get_retries()) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)
  httr::RETRY(
    "GET",
    glue::glue(
      "{url}/v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}.xml"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    xml2::as_list(.) %>%
    magrittr::extract2("data")
}

#' Get submissions for a list of submission instance IDs.
#'
#' Uses \code{\link{get_one_submission}} on a list of submission instance IDs
#' (`iid`) as returned from \code{\link{submission_list}$instance_id}.
#' By giving the list of `iid` to download explicitly, that list can be
#' modified using information not accessible to `ruODK`,
#' e.g. `iid` can be restricted to "only not already downloaded submissions".
#'
#' Forms with submission audit enabled will also receive the submission audit
#' as `audit.csv`. This will overwrite all previous `audit.csv` files.
#' To get the combined submission audit logs as one single, concatenated
#' `audit.csv` file, use `submission_export`.
#'
#' @param iid A list of submission instance IDs, e.g. from
#'   \code{\link{submission_list}$instance_id}.
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A nested list of submission data.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/retrieving-submission-xml}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # Step 1: Setup ruODK with OData Service URL (has url, pid, fid)
#' ruODK::ru_setup(svc = "...")
#'
#' # Step 2: List all submissions of form
#' sl <- submission_list()
#'
#' # Step 3: Get submissions
#' subs <- submission_get(sl$instance_id)
#' }
submission_get <- function(iid,
                           pid = get_default_pid(),
                           fid = get_default_fid(),
                           url = get_default_url(),
                           un = get_default_un(),
                           pw = get_default_pw(),
                           retries = get_retries()) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)
  tibble::tibble(
    iid = iid,
    pid = pid,
    fid = fid,
    url = url,
    un = un,
    pw = pw,
    retries = retries
  ) %>%
    purrr::pmap(ruODK::get_one_submission)
}

# usethis::use_test("submission_get") # nolint
