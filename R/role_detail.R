#' Show details of one Role.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Getting an individual Role reveals no additional information over
#' listing all Roles, but allows direct lookup of a specific Role.
#' The ID accepts the numeric ID of the Role, or a system name if the
#' Role has one (e.g. `admin` for the Administrator Role).
#' There are no authorization restrictions upon this endpoint.
#'
#' @param role_id The numeric ID of the Role, or its system name.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the Role's metadata as columns
#'   as per the ODK Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#getting-role-details}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' r <- role_detail("admin")
#'
#' r$verbs
#' }
role_detail <- function(
  role_id,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)

  if (missing(role_id) || length(role_id) != 1L || is.na(role_id)) {
    ru_msg_abort("role_id must be a single Role ID or system name.")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue("v1/roles/{role_id}"),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    (\(resp) {
      tibble::tibble(
        id = resp$id,
        name = resp$name %||% NA_character_,
        system = resp$system %||% NA_character_,
        verbs = list(unlist(resp$verbs)),
        created_at = resp$createdAt %||% NA_character_,
        updated_at = resp$updatedAt %||% NA_character_
      )
    })()
}

# usethis::use_test("role_detail")  # nolint
