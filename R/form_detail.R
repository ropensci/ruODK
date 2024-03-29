#' Show details for one form.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row and all form metadata as columns.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#getting-form-details}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' # With explicit credentials, see tests
#' fl <- form_list()
#'
#' # The first form in the test project
#' f <- form_detail(fid = fl$fid[[1]])
#'
#' # form_detail returns exactly one row
#' nrow(f)
#' # > 1
#'
#' # form_detail returns all form metadata as columns: name, xmlFormId, etc.
#' names(f)
#'
#' # > "name" "fid" "version" "state" "submissions" "created_at"
#' # > "created_by_id" "created_by" "updated_at" "published_at"
#' # > "last_submission" "hash"
#' }
form_detail <- function(pid = get_default_pid(),
                        fid = get_default_fid(),
                        url = get_default_url(),
                        un = get_default_un(),
                        pw = get_default_pw(),
                        retries = get_retries()) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  httr::RETRY(
    "GET",
    httr::modify_url(url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}"
      )
    ),
    httr::add_headers(
      "Accept" = "application/xml",
      "X-Extended-Metadata" = "true"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    { # nolint
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
        published_at = ifelse(
          is.null(.$publishedAt),
          NA_character_,
          .$publishedAt
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

# usethis::use_test("form_detail") # nolint
