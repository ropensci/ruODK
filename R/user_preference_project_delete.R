#' Delete a project preference of the authenticated User.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This removes a per-project preference previously stored with
#' `user_preference_project_set()`.
#'
#' @template param-pid
#' @param name (character) The name of the preference.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`).
#'   Central answers a successful delete with HTTP 200 and a bare body,
#'   which this function reports as `success`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#deleting-a-project-preference}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' user_preference_project_delete(name = "formTrashCollapsed")
#' # > $success
#' # > [1] TRUE
#' }
user_preference_project_delete <- function(
  pid = get_default_pid(),
  name,
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

  httr::RETRY(
    "DELETE",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/user-preferences/project/{pid}/",
        "{URLencode(name, reserved = TRUE)}"
      )
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    (\(resp) {
      if (is.list(resp) && !is.null(names(resp))) {
        janitor::clean_names(resp)
      } else {
        list(success = TRUE)
      }
    })()
}

# usethis::use_test("user_preference_project_delete")  # nolint
