#' List all Actors assigned some Project Role.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Given a Role, this endpoint lists all Actors that have been assigned that
#' Role upon this particular Project.
#' This endpoint requires ODK Central v0.5 or later.
#'
#' @template param-pid
#' @param role_id (character or numeric) The Role ID, typically the integer
#'   ID of the Role.
#'   A Role system name can also be supplied if the Role has one.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A tibble with one row for each Actor assigned the Role on the
#'   Project as per the ODK Central API docs.
#'   Column names are renamed from ODK's `camelCase` to `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#listing-all-actors-assigned-some-project-role}
# nolint end
#' @family project-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' pa <- project_assignment_actors(role_id = "manager")
#'
#' pa |> knitr::kable()
#' }
project_assignment_actors <- function(
  pid = get_default_pid(),
  role_id,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid)

  if (odkc_version |> semver_lt("0.5")) {
    ru_msg_warn("project_assignment_actors is supported from v0.5")
  }

  if (missing(role_id) || length(role_id) != 1L || is.na(role_id)) {
    ru_msg_abort("role_id must be a single Role ID.")
  }

  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue("v1/projects/{pid}/assignments/{role_id}")
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    purrr::list_transpose() |>
    tibble::as_tibble() |>
    janitor::clean_names() |>
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("project_assignment_actors")  # nolint
