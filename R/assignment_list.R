#' List all server-wide Assignments.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This lists every server-wide Assignment in the form of
#' `actor_id`/`role_id` pairs.
#' It does not list Project-specific Assignments; those need
#' `project_assignment_list()`.
#'
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row per Assignment and the columns
#'   `actor_id` and `role_id`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#listing-all-assignments}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' al <- assignment_list()
#'
#' al |> knitr::kable()
#' }
assignment_list <- function(
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)

  ru_http_request(
    "GET",
    url,
    path = "v1/assignments",
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    (\(resp) {
      tibble::tibble(
        actor_id = purrr::map_dbl(resp, "actorId"),
        role_id = purrr::map_dbl(resp, "roleId")
      )
    })()
}

# usethis::use_test("assignment_list")  # nolint
