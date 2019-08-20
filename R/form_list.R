#' List all forms.
#'
#'
#' @param pid The numeric ID of the project, e.g.: 3.
#' @template param-auth
#' @return A tibble with one row per form and all form metadata as columns.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/forms}
#' @family restful-api
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
  xml2list <- . %>%
    xml2::as_xml_document(.) %>%
    xml2::as_list(.)
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
        fid = purrr::map_chr(., "xmlFormId"),
        version = purrr::map_chr(., "version"),
        state = purrr::map_chr(., "state"),
        submissions = purrr::map_chr(., "submissions"),
        created_at = map_dttm_hack(., "createdAt"),
        created_by_id = purrr::map_int(., c("createdBy", "id")),
        created_by = purrr::map_chr(., c("createdBy", "displayName")),
        updated_at = map_dttm_hack(., "updatedAt"),
        last_submission = map_dttm_hack(., "lastSubmission"),
        hash = purrr::map_chr(., "hash")
      )
    }
}

# Tests
# usethis::edit_file("tests/testthat/test-form_list.R")
