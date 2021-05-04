#' List all projects.
#'
#'
#' While the API endpoint will return all projects,
#' \code{\link{project_list}} will fail with incorrect or missing
#' authentication.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-orders
#' @template param-tz
#' @return A tibble with one row per project and all project metadata
#'         as columns as per ODK Central API docs.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/project-management/projects/listing-projects}
# nolint end
#' @family project-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
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
                         retries = get_retries(),
                         orders = c("YmdHMS",
                                    "YmdHMSz",
                                    "Ymd HMS",
                                    "Ymd HMSz",
                                    "Ymd",
                                    "ymd"),
                         tz = get_default_tz()) {
  yell_if_missing(url, un, pw)
  httr::RETRY(
    "GET",
    httr::modify_url(url, path = glue::glue("v1/projects")),
    httr::add_headers("Accept" = "application/xml",
                      "X-Extended-Metadata" = "true"),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    tibble::tibble(.) %>%
    tidyr::unnest_wider(".", names_repair = "universal") %>%
    janitor::clean_names(.) %>%
    dplyr::mutate_at(
      dplyr::vars("last_submission", "created_at", "updated_at"),
      ~ isodt_to_local(., orders = orders, tz = tz)
    ) %>%
    {
      if ("archived" %in% names(.)) {
        dplyr::mutate(., archived = tidyr::replace_na(archived, FALSE))
      } else {
        .
      }
    }

}

# usethis::use_test("project_list") # nolint
