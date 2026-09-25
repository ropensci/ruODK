#' Create a new project.
#'
#' `r lifecycle::badge('experimental')`
#'
#' @param name The desired name of the project. Can contain whitespace.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the new Project's metadata as columns,
#'         as per ODK Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#creating-a-project}
# nolint end
#' @family project-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
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
project_create <- function(
  name,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)

  if (
    !is.character(name) || length(name) != 1L || is.na(name) || !nzchar(name)
  ) {
    ru_msg_abort("name must be a single non-empty character string.")
  }

  resp <- ru_http_request(
    "POST",
    url,
    path = "v1/projects",
    un = un,
    pw = pw,
    body = list(name = name),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content()
  tibble::tibble(
    id = resp$id,
    name = resp$name,
    archived = resp$archived %||% FALSE
  )
}

# usethis::use_test("project_create")  # nolint
