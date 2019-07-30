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
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' fl <- form_list(1)
#'
#' # With explicit credentials, see tests
#' fl <- form_list(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#'
#' class(fl)
#' # > c("tbl_df", "tbl", "data.frame")
#' }
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
        createdAt = map_dttm_hack(., "createdAt"),
        createdById = purrr::map_int(., c("createdBy", "id")),
        createdBy = purrr::map_chr(., c("createdBy", "displayName")),
        updatedAt = map_dttm_hack(., "updatedAt"),
        lastSubmission = map_dttm_hack(., "lastSubmission"),
        hash = purrr::map_chr(., "hash"),
        xml = purrr::map_chr(., "xml"),
      )
    }
}
