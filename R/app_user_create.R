#' Create a new App User.
#'
#' `r lifecycle::badge("experimental")`
#'
#' The only information required to create a new App User is its display
#' name (called "Nickname" in the administration panel).
#' When an App User is created, it is assigned no rights.
#' To grant rights, assign the App User a Form Role with
#' `form_assignment_grant()`.
#'
#' @template param-pid
#' @param display_name (character) The friendly nickname of the App User
#'   to create.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the new App User's metadata as
#'   columns, including the `token` to authenticate requests as this App
#'   User.
#'   The token is only returned at creation time.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#creating-a-new-app-user}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' au <- app_user_create(display_name = "My App User")
#'
#' au |> knitr::kable()
#' }
app_user_create <- function(
  pid = get_default_pid(),
  display_name,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid)

  if (
    missing(display_name) ||
      !is.character(display_name) ||
      length(display_name) != 1L ||
      is.na(display_name) ||
      !nzchar(display_name)
  ) {
    ru_msg_abort("display_name must be a single non-empty character string.")
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue("v1/projects/{pid}/app-users"),
    un = un,
    pw = pw,
    body = list(displayName = display_name),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    (\(resp) {
      tibble::tibble(
        id = resp$id,
        display_name = resp$displayName %||% NA_character_,
        type = resp$type %||% NA_character_,
        token = resp$token %||% NA_character_,
        project_id = resp$projectId %||% NA_integer_,
        created_at = resp$createdAt %||% NA_character_,
        updated_at = resp$updatedAt %||% NA_character_
      )
    })()
}

# usethis::use_test("app_user_create")  # nolint
