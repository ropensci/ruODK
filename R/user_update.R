#' Modify a User.
#'
#' `r lifecycle::badge("experimental")`
#'
#' JSON data can be patched to update User details.
#' The display name sets the friendly name the web interface uses to refer
#' to the User.
#' The email sets the email address associated with the account.
#' When User details are updated, the updatedAt field is updated
#' automatically.
#'
#' @param actor_id (numeric) The integer ID of the User.
#' @param display_name (character) The friendly display name to associate
#'   with this User.
#'   Default: `NULL` (left unchanged).
#' @param email (character) The email address to associate with this User.
#'   Default: `NULL` (left unchanged).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the User's metadata as columns.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#modifying-a-user}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' ul <- user_list()
#'
#' u <- user_update(actor_id = ul$id[[1]], display_name = "New Name")
#'
#' u |> knitr::kable()
#' }
user_update <- function(
  actor_id,
  display_name = NULL,
  email = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)

  if (missing(actor_id) || length(actor_id) != 1L || is.na(actor_id)) {
    ru_msg_abort("actor_id must be a single Actor ID.")
  }

  body <- list()
  if (!is.null(display_name)) {
    body$displayName <- display_name
  }
  if (!is.null(email)) {
    body$email <- email
  }
  if (length(body) == 0L) {
    ru_msg_abort("One of display_name or email must be given.")
  }

  ru_http_request(
    "PATCH",
    url,
    path = glue::glue("v1/users/{actor_id}"),
    un = un,
    pw = pw,
    body = body,
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    (\(resp) {
      tibble::tibble(
        id = resp$id,
        display_name = resp$displayName %||% NA_character_,
        type = resp$type %||% NA_character_,
        email = resp$email %||% NA_character_,
        created_at = resp$createdAt %||% NA_character_,
        updated_at = resp$updatedAt %||% NA_character_
      )
    })()
}

# usethis::use_test("user_update")  # nolint
