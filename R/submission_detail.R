#' Show details for one submission.
#'
#' @template param-pid
#' @template param-fid
#' @template param-iid
#' @template param-auth
#' @return A nested list of submission metadata.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/getting-submission-details}
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
#'   get_test_pid(),
#'   get_test_fid(),
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' sub <- submission_detail(
#'   get_test_pid(),
#'   get_test_fid(),
#'   sl$instance_id[[1]],
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' # The details for one submission return exactly one row
#' nrow(sub)
#' # > 1
#'
#' # The columns are metadata, plus the submission data in column 'xml`
#' names(sub)
#' # > "instance_id" "submitter_id" "submitter" "created_at" "updated_at"
#' }
submission_detail <- function(pid,
                              fid,
                              iid,
                              url = get_default_url(),
                              un = get_default_un(),
                              pw = get_default_pw()) {
  . <- NULL
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
