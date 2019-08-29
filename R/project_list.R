#' List all projects.
#'
#'
#' While the API endpoint will return all projects,
#' `project_list` will fail with incorrect or missing authentication.
#'
#' @template param-auth
#' @return A tibble with one row per project and all project metadata
#'         as columns as per ODK Central API docs.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/project-management/projects/listing-projects}
#' @family restful-api
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @importFrom readr parse_datetime
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' pl <- project_list()
#'
#' # With explicit credentials, see tests
#' p <- project_list(
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#' )
#' knitr::kable(p)
#'
#' # project_list returns a tibble
#' class(p)
#' # > "tbl_df" "tbl" "data.frame"
#'
#' # columns are project metadata
#' names(p)
#' # > "id" "name" "forms" "app_users" "last_submission"
#' # > "created_at" "updated_at" "archived"
#' }
project_list <- function(url = get_default_url(),
                         un = get_default_un(),
                         pw = get_default_pw()) {
  . <- NULL
  yell_if_missing(url, un, pw)
  glue::glue("{url}/v1/projects/") %>%
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
        id = purrr::map_int(., "id"),
        name = purrr::map_chr(., "name"),
        forms = purrr::map_int(., "forms"),
        app_users = purrr::map_int(., "appUsers"),
        last_submission = map_dttm_hack(., "lastSubmission"),
        created_at = map_dttm_hack(., "createdAt"),
        updated_at = map_dttm_hack(., "updatedAt"),
        archived = ifelse(
          is.null(.$archived),
          FALSE,
          TRUE
        )
      )
    }
}

# Tests
# usethis::edit_file("tests/testthat/test-project_list.R")