#' Create a new project.
#'
#' \lifecycle{experimental}
#'
#' @param name The desired name of the project. Can contain whitespace.
#' @template param-url
#' @template param-auth
#' @return A tibble with one row per project and all project metadata
#'         as columns as per ODK Central API docs.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/project-management/projects/creating-a-project}
# nolint end
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = paste0(
#'     "https://sandbox.central.opendatakit.org/v1/projects/14/",
#'     "forms/build_Flora-Quadrat-0-2_1558575936.svc"
#'   ),
#'   un = "me@email.com",
#'   pw = "..."
#' )
#'
#' p <- project_create("Test Project")
#' knitr::kable(p)
#'
#' # project_create returns a tibble
#' class(p)
#' # > "tbl_df" "tbl" "data.frame"
#'
#' # columns are project metadata
#' names(p)
#' # > "id" "name" "archived"
#' }
project_create <- function(name,
                           url = get_default_url(),
                           un = get_default_un(),
                           pw = get_default_pw()) {
  rlang::warn("Not implemented.")

  # has_internet()
  # glue::glue("{url}/v1/projects/") %>%
  #   httr::POST(
  #     config = list(
  #       httr::add_headers("Content-Type" = "application/json"),
  #       httr::authenticate(un, pw)
  #     ),
  #     body = jsonlite::toJSON(list(name = "x"), auto_unbox = T),
  #     encode = "json"
  #   ) %>%
  #   httr::stop_for_status(
  #     task = glue::glue("create a project with name {name}")
  #   ) %>%
  #   httr::content(.) %>%
  #   {
  #     tibble::tibble(
  #       id = purrr::map_int(., "id"),
  #       name = purrr::map_chr(., "name"),
  #       archived = ifelse(is.null(.$archived), FALSE, TRUE)
  #     )
  #   }
}


# Tests
# usethis::edit_file("tests/testthat/test-project_create.R")
