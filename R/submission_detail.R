#' Show metadata for one submission.
#'
#' \lifecycle{stable}
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @return A nested list of submission metadata.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/getting-submission-details}
# nolint end
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
#' sl <- submission_list()
#'
#' sub <- submission_detail(sl$instance_id[[1]])
#'
#' # The details for one submission return exactly one row
#' nrow(sub)
#' # > 1
#'
#' # The columns are metadata about the submission
#' names(sub)
#' # > "instance_id" "submitter_id" "submitter" "created_at" "updated_at"
#' }
submission_detail <- function(iid,
                              pid = get_default_pid(),
                              fid = get_default_fid(),
                              url = get_default_url(),
                              un = get_default_un(),
                              pw = get_default_pw()) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}/submissions/{iid}") %>%
    httr::GET(
      httr::add_headers(
        "Accept" = "application/json; extended",
        "X-Extended-Metadata" = "true"
      ),
      httr::authenticate(un, pw)
    ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    {
      tibble::tibble(
        instance_id = .$instanceId,
        submitter_id = .$submitter$id,
        submitter = .$submitter$displayName,
        created_at = readr::parse_datetime(
          .$createdAt,
          format = "%Y-%m-%dT%H:%M:%OS%Z"
        ),
        updated_at = ifelse(
          is.null(.$updatedAt),
          NA,
          readr::parse_datetime(
            .$updatedAt,
            format = "%Y-%m-%dT%H:%M:%OS%Z"
          )
        )
      )
    }
}

# Tests
# usethis::edit_file("tests/testthat/test-submission_detail.R")
