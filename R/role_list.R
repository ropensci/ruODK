#' List all Roles.
#'
#' `r lifecycle::badge("experimental")`
#'
#' The Roles API lists and describes each known Role within the system.
#' Each Role holds the verbs it allows its assignees to perform.
#' There are no authorization restrictions upon this endpoint: anybody
#' is allowed to list all Role information at any time.
#'
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-orders
#' @template param-tz
#' @return A tibble with one row per Role and all Role metadata as
#'   columns as per the ODK Central API docs.
#'   The `verbs` column is a list of character vectors.
#'   Other column names are renamed from ODK Central's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#listing-all-roles}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' rl <- role_list()
#'
#' rl |> dplyr::select(id, name, system) |> knitr::kable()
#' }
role_list <- function(
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw)

  resp <- ru_http_request(
    "GET",
    url,
    path = "v1/roles",
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json()

  tibble::tibble(roles = resp) |>
    tidyr::unnest_wider("roles", names_repair = "universal") |>
    janitor::clean_names() |>
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("role_list")  # nolint
