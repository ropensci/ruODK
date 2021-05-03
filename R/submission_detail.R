#' Show metadata for one submission.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A nested list of submission metadata.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/getting-submission-details}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' sl <- submission_list()
#'
#' sub <- submission_detail(sl$instance_id[[1]])
#'
#' # The details for one submission return exactly one row
#' nrow(sub)
#' # > 1
#'
#' # The columns are metadata about the submission and the submitter
#' names(sub)
#' # > "instance_id" "submitter_id" "submitter_type" "submitter_display_name"
#' # > "submitter_created_at" "device_id" "created_at"
#' }
submission_detail <- function(iid,
                              pid = get_default_pid(),
                              fid = get_default_fid(),
                              url = get_default_url(),
                              un = get_default_un(),
                              pw = get_default_pw(),
                              retries = get_retries()) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/submissions/{iid}"
      )
    ),
    httr::add_headers(
      "Accept" = "application/json; extended",
      "X-Extended-Metadata" = "true"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    { # nolint
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

# usethis::use_test("submission_detail") # nolint
