#' Download server audit logs for one submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This function is the workhorse for the vectorised function
#' submission_audit_get,
#' which gets all server audit logs for a list of submission IDs.
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
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#retrieving-audit-logs}
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
#' sub <- get_one_submission_audit(sl$instance_id[[1]])
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
get_one_submission_audit <- function(iid,
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
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}/audits"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.)
  # %>%
  #   tibble::as_tibble() %>%
  #   tidyr::unnest_wider()
}

#' Get submission audits for a list of submission instance IDs.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Uses \code{\link{get_one_submission_audit}} on a list of submission
#' instance IDs
#' (`iid`) as returned from \code{\link{submission_list}$instance_id}.
#' By giving the list of `iid` to download explicitly, that list can be
#' modified using information not accessible to `ruODK`,
#' e.g. `iid` can be restricted to "only not already downloaded submissions".
#'
#' To get the combined submission audit logs for one form
#' as one single, concatenated `audit.csv` file, use `submission_export`.
#'
#' @param iid A list of submission instance IDs, e.g. from
#'   \code{\link{submission_list}$instance_id}.
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A nested list of submission audit logs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#retrieving-submission-xml}
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
#' # Step 3: Get submission audit logs
#' sa <- submission_audit_get(sl$instance_id)
#' }
submission_audit_get <- function(iid,
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
    purrr::pmap(ruODK::get_one_submission_audit)
}

# usethis::use_test("submission_get_audit") # nolint
