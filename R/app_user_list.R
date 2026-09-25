#' List all App Users of a Project.
#'
#' `r lifecycle::badge("experimental")`
#'
#' App Users may only be created, fetched, and manipulated within the nested
#' Projects subresource, as App Users themselves are limited to the Project
#' in which they are created.
#'
#' @template param-pid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-orders
#' @template param-tz
#' @return A tibble with one row for each App User of the Project as per the
#'   ODK Central API docs.
#'   Column names are renamed from ODK's `camelCase` to `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#listing-all-app-users}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' au <- app_user_list()
#'
#' au |> knitr::kable()
#' }
app_user_list <- function(
  pid = get_default_pid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid)

  ru_http_request(
    "GET",
    url,
    path = glue::glue("v1/projects/{pid}/app-users"),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    purrr::list_transpose() |>
    tibble::as_tibble() |>
    janitor::clean_names() |>
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("app_user_list")  # nolint
