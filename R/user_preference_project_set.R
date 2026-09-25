#' Set a project preference of the authenticated User.
#'
#' `r lifecycle::badge("experimental")`
#'
#' The Central frontend uses this API to save various user preferences,
#' such as the sorting order of certain listings.
#' The preference value may be of any JSON-serializable type.
#'
#' @template param-pid
#' @param name (character) The name of the preference.
#' @param value The preference value to store.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#setting-a-project-preference}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' user_preference_project_set(name = "formTrashCollapsed", value = TRUE)
#' # > $success
#' # > [1] TRUE
#' }
user_preference_project_set <- function(
  pid = get_default_pid(),
  name,
  value,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid)

  if (
    missing(name) ||
      !is.character(name) ||
      length(name) != 1L ||
      is.na(name) ||
      !nzchar(name)
  ) {
    ru_msg_abort("name must be a single non-empty character string.")
  }
  if (missing(value)) {
    ru_msg_abort("value must be given.")
  }

  ru_http_request(
    "PUT",
    url,
    path = glue::glue(
      "v1/user-preferences/project/{pid}/",
      "{URLencode(name, reserved = TRUE)}"
    ),
    un = un,
    pw = pw,
    body = list(propertyValue = value),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("user_preference_project_set")  # nolint
