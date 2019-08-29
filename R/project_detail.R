#' List all details of one project.
#'
#' While the API endpoint will return all details for one project,
#' `project_detail` will fail with incorrect or missing authentication.
#'
#' @param pid The numeric ID of the project, e.g.: 1.
#' @template param-auth
#' @return A tibble with exactly one row for the project and all project
#'   metadata as columns as per ODK Central API docs.
#'   Column names are renamed from ODK's `camelCase` to `snake_case`.
#'   Values differ to values returned by ODK Central API:
#'
#'   * archived: FALSE (if NULL) else TRUE
#'   * dates: NA if NULL
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/project-management/projects/getting-project-details}
#' @family restful-api
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @importFrom readr parse_datetime
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' pd <- project_detail(1)
#'
#' # With explicit credentials, see tests
#' pd <- project_detail(
#'   1,
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#'
#' pd %>%
#'   dplyr::select(-"verbs") %>%
#'   knitr::kable(.)
#' }
project_detail <- function(pid,
                           url = get_default_url(),
                           un = get_default_un(),
                           pw = get_default_pw()) {
  . <- NULL
  yell_if_missing(url, un, pw, pid)
  p <- glue::glue("{url}/v1/projects/{pid}") %>%
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
        id = .$id,
        name = .$name,
        forms = .$forms,
        app_users = .$appUsers,
        last_submission = ifelse(
          is.null(.$lastSubmission),
          NA_character_,
          .$lastSubmission
        ),
        created_at = .$createdAt,
        updated_at = ifelse(
          is.null(.$updatedAt),
          NA_character_,
          .$updatedAt
        ),
        archived = ifelse(
          is.null(.$archived),
          FALSE,
          TRUE
        ),
        verbs = list(.$verbs)
      )
    }
}

# Tests
# usethis::edit_file("tests/testthat/test-project_detail.R")
