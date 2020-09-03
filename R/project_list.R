#' List all projects.
#'
#'
#' While the API endpoint will return all projects,
#' \code{\link{project_list}} will fail with incorrect or missing
#' authentication.
#'
#' \lifecycle{stable}
#'
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row per project and all project metadata
#'         as columns as per ODK Central API docs.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/project-management/projects/listing-projects}
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
#' pl <- project_list()
#' knitr::kable(pl)
#'
#' # project_list returns a tibble
#' class(pl)
#' # > "tbl_df" "tbl" "data.frame"
#'
#' # columns are project metadata
#' names(pl)
#' # > "id" "name" "forms" "app_users" "created_at" "updated_at"
#' # > "last_submission" "archived"
#' }
project_list <- function(url = get_default_url(),
                         un = get_default_un(),
                         pw = get_default_pw(),
                         retries = get_retries()) {
  yell_if_missing(url, un, pw)
  httr::RETRY(
    "GET",
    httr::modify_url(url, path = glue::glue("v1/projects")),
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
        id = purrr::map_int(., "id"),
        name = purrr::map_chr(., "name"),
        forms = purrr::map_int(., "forms"),
        app_users = purrr::map_int(., "appUsers"),
        created_at = purrr::map_chr(., "createdAt", .default = NA) %>%
          isodt_to_local(),
        updated_at = purrr::map_chr(., "updated_at", .default = NA) %>%
          isodt_to_local(),
        last_submission = purrr::map_chr(., "lastSubmission", .default = NA) %>%
          isodt_to_local(),
        archived = purrr::map_lgl(., "archived", .default = FALSE)
      )
    }
}

# usethis::use_test("project_list") # nolint
