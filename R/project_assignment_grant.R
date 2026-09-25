#' Assign an Actor to a Project Role.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Given a Role and an Actor, this endpoint assigns that Role to that Actor
#' for this particular Project.
#' No request body data is required.
#' This endpoint requires ODK Central v0.5 or later.
#'
#' @template param-pid
#' @param role_id (character or numeric) The Role ID, typically the integer
#'   ID of the Role.
#'   A Role system name can also be supplied if the Role has one.
#' @param actor_id (numeric) The integer ID of the Actor.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#assigning-an-actor-to-a-project-role}
# nolint end
#' @family project-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' project_assignment_grant(role_id = "manager", actor_id = 14)
#' # > $success
#' # > [1] TRUE
#' }
project_assignment_grant <- function(
  pid = get_default_pid(),
  role_id,
  actor_id,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version()
) {
  yell_if_missing(url, un, pw, pid = pid)

  if (odkc_version |> semver_lt("0.5")) {
    ru_msg_warn("project_assignment_grant is supported from v0.5")
  }

  if (missing(role_id) || length(role_id) != 1L || is.na(role_id)) {
    ru_msg_abort("role_id must be a single Role ID.")
  }
  if (missing(actor_id) || length(actor_id) != 1L || is.na(actor_id)) {
    ru_msg_abort("actor_id must be a single Actor ID.")
  }

  httr::RETRY(
    "POST",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/assignments/{role_id}/{actor_id}"
      )
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("project_assignment_grant")  # nolint
