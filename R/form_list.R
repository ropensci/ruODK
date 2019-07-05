#' List all forms.
#'
#'
#' See https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/forms
#'
#' @param pid The numeric ID of the project, e.g.: 3.
#' @template param-auth
#' @return A tibble with one row per form and all form metadata as columns.
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @importFrom readr parse_datetime
#' @import magrittr
#' @export
form_list <- function(pid,
                      url = Sys.getenv("ODKC_URL"),
                      un = Sys.getenv("ODKC_UN"),
                      pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue("{url}/v1/projects/{pid}/forms") %>%
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
        name = purrr::map_chr(., "name"),
        xmlFormId = purrr::map_chr(., "xmlFormId"),
        version = purrr::map_chr(., "version"),
        state = purrr::map_chr(., "state"),
        submissions = purrr::map_chr(., "submissions"),
        createdAt = purrr::map_chr(., "createdAt") %>% readr::parse_datetime(., format = "%Y-%m-%dT%H:%M:%OS%Z"),
        createdById = purrr::map_int(., c("createdBy", "id")),
        createdBy = purrr::map_chr(., c("createdBy", "displayName")),
        updatedAt = map_chr_hack(., "updatedAt") %>% readr::parse_datetime(., format = "%Y-%m-%dT%H:%M:%OS%Z"),
        lastSubmission = map_chr_hack(., "lastSubmission") %>% readr::parse_datetime(., format = "%Y-%m-%dT%H:%M:%OS%Z"),
        hash = purrr::map_chr(., "hash"),
        xml = purrr::map_chr(., "xml"),
      )
    }
}
