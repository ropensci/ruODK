#' List all details of one project.
#'
#' While the API endpoint will return all details for one project,
#' \code{\link{project_detail}} will fail with incorrect or missing
#' authentication.
#'
#' \lifecycle{stable}
#'
#' @template param-pid
#' @template param-url
#' @template param-auth
#' @return A tibble with exactly one row for the project and all project
#'   metadata as columns as per ODK Central API docs.
#'   Column names are renamed from ODK's `camelCase` to `snake_case`.
#'   Values differ to values returned by ODK Central API:
#'
#'   * archived: FALSE (if NULL) else TRUE
#'   * dates: NA if NULL
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/project-management/projects/getting-project-details}
# nolint end
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = paste0(
#'     "https://sandbox.central.getodk.org/v1/projects/14/",
#'     "forms/build_Flora-Quadrat-0-2_1558575936.svc"
#'   ),
#'   un = "me@email.com",
#'   pw = "..."
#' )
#'
#' pd <- project_detail()
#'
#' pd %>%
#'   dplyr::select(-"verbs") %>%
#'   knitr::kable(.)
#' }
project_detail <- function(pid = get_default_pid(),
                           url = get_default_url(),
                           un = get_default_un(),
                           pw = get_default_pw()) {
  yell_if_missing(url, un, pw, pid = pid)
  httr::RETRY(
    "GET",
    glue::glue("{url}/v1/projects/{pid}"),
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
