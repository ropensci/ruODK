#' List all Assignments of one Project.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This lists every Assignment upon the given Project in the form of
#' `actor_id`/`role_id` pairs.
#' Assigning an Actor a Role grants that Actor the Role's verbs anywhere
#' within the Project.
#'
#' @template param-pid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row per Assignment and the columns
#'   `actor_id` and `role_id`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#listing-all-project-assignments}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' al <- project_assignment_list()
#'
#' al |> knitr::kable()
#' }
project_assignment_list <- function(
  pid = get_default_pid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid)

  httr::RETRY(
    "GET",
    httr::modify_url(url, path = glue::glue("v1/projects/{pid}/assignments")),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    (\(resp) {
      tibble::tibble(
        actor_id = purrr::map_dbl(resp, "actorId"),
        role_id = purrr::map_dbl(resp, "roleId")
      )
    })()
}

# usethis::use_test("project_assignment_list")  # nolint
