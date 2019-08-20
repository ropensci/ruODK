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
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#'
#' sub <- submission_detail(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   sl$instance_id[[1]],
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
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
                              url = Sys.getenv("ODKC_URL"),
                              un = Sys.getenv("ODKC_UN"),
                              pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue(
    "{url}/v1/projects/{pid}/forms/{fid}/submissions/{iid}"
  ) %>%
    httr::GET(
      httr::add_headers(
        "Accept" = "application/json; extended",
        "X-Extended-Metadata" = "true"
      ),
      httr::authenticate(un, pw)
    ) %>%
    httr::stop_for_status() %>%
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
