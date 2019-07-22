#' List all details of one project.
#'
#'
#' See https://odkcentral.docs.apiary.io/#reference/project-management/projects/getting-project-details
#'
#' While the API endpoint will return all details for one project,
#' `project_list` will fail with incorrect or missing authentication.
#'
#' @param pid The numeric ID of the project, e.g.: 3.
#' @template param-auth
#' @return A tibble with exactly one row for the project and all project metadata
#'   as columns as per ODK Central API docs.
#'   Values differ to values returned by ODK Central API:
#'
#'   * archived: FALSE (if NULL) else TRUE
#'   * dates: NA if NULL
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @importFrom readr parse_datetime
#' @export
project_detail <- function(pid,
                           url = Sys.getenv("ODKC_URL"),
                           un = Sys.getenv("ODKC_UN"),
                           pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  p <- glue::glue("{url}/v1/projects/{pid}") %>%
    httr::GET(
      httr::add_headers(
        "Accept" = "application/xml",
        "X-Extended-Metadata" = "true"
      ),
      httr::authenticate(un, pw)
    ) %>%
    httr::stop_for_status() %>%
    httr::content(.) %>%
    {
      tibble::tibble(
        id = .$id,
        name = .$name,
        forms = .$forms,
        appUsers = .$appUsers,
        createdAt = .$createdAt,
        updatedAt = ifelse(
          is.null(.$updatedAt),
          NA_character_,
          .$updatedAt
        ),
        lastSubmission = ifelse(
          is.null(.$lastSubmission),
          NA_character_,
          .$lastSubmission
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
