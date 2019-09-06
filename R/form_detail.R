#' Show details for one form.
#'
#'
#' @template param-pid
#' @template param-fid
#' @template param-auth
#' @return A tibble with one row and all form metadata as columns.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/'-individual-form}
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' fl <- form_list(1)
#'
#' # With explicit credentials, see tests
#' fl <- form_list(
#'   get_test_pid(),
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' # The first form in the test project
#' f <- form_detail(
#'   get_test_pid(),
#'   fl$fid[[1]],
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' # form_detail returns exactly one row
#' nrow(f)
#' # > 1
#'
#' # form_detail returns all form metadata as columns: name, xmlFormId, etc.
#' names(f)
#'
#' # > "name" "fid" "version" "state" "submissions" "created_at"
#' # > "created_by_id" "created_by" "updated_at" "last_submission" "hash"
#' }
form_detail <- function(pid,
                        fid,
                        url = get_default_url(),
                        un = get_default_un(),
                        pw = get_default_pw()) {
  . <- NULL
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}") %>%
    httr::GET(
      httr::add_headers(
        "Accept" = "application/xml",
        "X-Extended-Metadata" = "true"
      ),
      httr::authenticate(un, pw)
    ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    {
      tibble::tibble(
        name = .$name,
        fid = .$xmlFormId,
        version = .$version,
        state = .$state,
        submissions = .$submissions,
        created_at = .$createdAt,
        created_by_id = .$createdBy$id,
        created_by = .$createdBy$displayName,
        updated_at = ifelse(
          is.null(.$updatedAt),
          NA_character_,
          .$updatedAt
        ),
        last_submission = ifelse(
          is.null(.$lastSubmission),
          NA_character_,
          .$lastSubmission
        ),
        hash = .$hash
      )
    }
}

# Tests
# usethis::edit_file("tests/testthat/test-form_detail.R")
