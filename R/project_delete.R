#' Delete a Project.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Deleting a Project removes it from the management interface and makes
#' it permanently inaccessible.
#' Do not do this unless you are certain you will never need any of its
#' data again.
#'
#' @template param-pid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#deleting-a-project}
# nolint end
#' @family project-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' p <- project_create("Temporary Project")
#'
#' project_delete(p$id)
#' # > $success
#' # > [1] TRUE
#' }
project_delete <- function(
  pid = get_default_pid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid)

  ru_http_request(
    "DELETE",
    url,
    path = glue::glue("v1/projects/{pid}"),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("project_delete")  # nolint
