#' Assign an Actor to a server-wide Role.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Given a Role and an Actor, this endpoint assigns that Role to that Actor
#' upon all system objects.
#' No request body data is required.
#' This endpoint requires ODK Central v0.5 or later.
#'
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
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#assigning-an-actor-to-a-server-wide-role}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' assignment_grant(role_id = "admin", actor_id = 14)
#' # > $success
#' # > [1] TRUE
#' }
assignment_grant <- function(
  role_id,
  actor_id,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version()
) {
  yell_if_missing(url, un, pw)

  if (odkc_version |> semver_lt("0.5")) {
    ru_msg_warn("assignment_grant is supported from v0.5")
  }

  if (missing(role_id) || length(role_id) != 1L || is.na(role_id)) {
    ru_msg_abort("role_id must be a single Role ID.")
  }
  if (missing(actor_id) || length(actor_id) != 1L || is.na(actor_id)) {
    ru_msg_abort("actor_id must be a single Actor ID.")
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue("v1/assignments/{role_id}/{actor_id}"),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("assignment_grant")  # nolint
