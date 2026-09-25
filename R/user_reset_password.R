#' Initiate a User password reset.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Anybody can initiate a reset of any User's password.
#' An email is sent with instructions on how to complete the password reset;
#' it contains a token that is required to complete the process.
#' If the email address provided does not match any User in the system, that
#' address is still sent an email informing them of the attempt and that no
#' account was found.
#'
#' @param email (character) The email address of the User account whose
#'   password is to be reset.
#' @param invalidate (lgl) If `TRUE`, the User's current password is
#'   immediately invalidated, regardless of whether the reset is completed.
#'   This requires an authenticated User with permission to do this.
#'   Default: `FALSE`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#initating-a-password-reset}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' user_reset_password(email = "my.email.address@getodk.org")
#' # > $success
#' # > [1] TRUE
#' }
user_reset_password <- function(
  email,
  invalidate = FALSE,
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

  query <- NULL
  if (isTRUE(invalidate)) {
    query <- list("invalidate" = "true")
  }

  ru_http_request(
    "POST",
    url,
    path = "v1/users/reset/initiate",
    query = query,
    un = un,
    pw = pw,
    body = list(email = email),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("user_reset_password")  # nolint
