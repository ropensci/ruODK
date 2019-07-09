#' List all projects.
#'
#'
#' See https://odkcentral.docs.apiary.io/#reference/project-management/projects/listing-projects
#'
#' While the API endpoint will return all projects
#' `project_list` will fail with incorrect or missing authentication.
#'
#' @template param-auth
#' @return A tibble with one row per project and all project metadata
#'         as columns as per ODK Central API docs.
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @importFrom readr parse_datetime
#' @import magrittr
#' @export
project_list <- function(url = Sys.getenv("ODKC_URL"),
                         un = Sys.getenv("ODKC_UN"),
                         pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue("{url}/v1/projects/") %>%
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
        id = purrr::map_int(., "id"),
        name = purrr::map_chr(., "name"),
        archived = map_chr_hack(., "archived"),
        forms = purrr::map_int(., "forms"),
        appUsers = purrr::map_int(., "appUsers"),
        lastSubmission = map_dttm_hack(., "lastSubmission"),
        createdAt = map_dttm_hack(., "createdAt"),
        updatedAt = map_dttm_hack(., "updatedAt")
      )
    }
}
