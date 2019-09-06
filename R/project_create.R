#' Create a new project.
#'
#' @param name The desired name of the project. Can contain whitespace.
#' @template param-auth
#' @return A tibble with one row per project and all project metadata
#'         as columns as per ODK Central API docs.
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/project-management/projects/creating-a-project}
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' p <- project_create("Test Project")
#'
#' # With explicit credentials, see tests
#' p <- project_create(
#'   "Test Project",
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
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
                           url = Sys.getenv("ODKC_URL"),
                           un = Sys.getenv("ODKC_UN"),
                           pw = Sys.getenv("ODKC_PW")) {
  rlang::warn("Not implemented.")

  # . <- NULL
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
