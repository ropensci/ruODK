#' Create a new User.
#'
#' `r lifecycle::badge("experimental")`
#'
#' All that is required to create a new User is an email address.
#' That email address will receive a message instructing the new User on how
#' to claim the new account and set a password.
#' Optionally, a password may also be supplied as a part of this request.
#' If it is, the account is immediately usable with the given credentials.
#' Users are not able to do anything upon creation besides log in and change
#' their own profile information.
#' To allow Users to perform useful actions, assign them one or more Roles.
#'
#' @param email (character) The email address of the User account to create.
#' @param password (character) If provided, the User account is created with
#'   this password.
#'   Default: `NULL` (the User sets the password later).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the new User's metadata as columns.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#creating-a-new-user}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' u <- user_create(email = "new.user@example.com")
#'
#' u |> knitr::kable()
#' }
user_create <- function(
  email,
  password = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)

  if (
    missing(email) ||
      !is.character(email) ||
      length(email) != 1L ||
      is.na(email) ||
      !nzchar(email)
  ) {
    ru_msg_abort("email must be a single non-empty character string.")
  }
  if (
    !is.null(password) &&
      (!is.character(password) ||
        length(password) != 1L ||
        is.na(password) ||
        !nzchar(password))
  ) {
    ru_msg_abort("password must be a single non-empty character string.")
  }

  body <- list(email = email)
  if (!is.null(password)) {
    body$password <- password
  }

  httr::RETRY(
    "POST",
    httr::modify_url(url, path = "v1/users"),
    httr::add_headers("Accept" = "application/json"),
    body = body,
    encode = "json",
    httr::authenticate(un, pw),
    times = retries
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

# usethis::use_test("user_create")  # nolint
