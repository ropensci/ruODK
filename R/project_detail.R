#' List all details of one project.
#'
#' While the API endpoint will return all details for one project,
#' \code{\link{project_detail}} will fail with incorrect or missing
#' authentication.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-pid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with exactly one row for the project and all project
#'   metadata as columns as per ODK Central API docs.
#'   Column names are renamed from ODK's `camelCase` to `snake_case`.
#'   Values differ to values returned by ODK Central API:
#'
#'   * archived: FALSE (if NULL) else TRUE
#'   * dates: NA if NULL
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#getting-project-details}
# nolint end
#' @family project-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
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
                           pw = get_default_pw(),
                           retries = get_retries()) {
  yell_if_missing(url, un, pw, pid = pid)
  httr::RETRY(
    "GET",
    httr::modify_url(url, path = glue::glue("v1/projects/{pid}")),
    httr::add_headers(
      "Accept" = "application/xml",
      "X-Extended-Metadata" = "true"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content() %>%
    { # nolint
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

# usethis::use_test("project_detail") # nolint
