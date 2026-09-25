#' Directly update a User password.
#'
#' `r lifecycle::badge("experimental")`
#'
#' To directly update a User password, the User's intention must be reproven
#' by supplying the old password alongside the new password.
#' To initiate an email-based password reset process instead, see
#' `user_reset_password()`.
#'
#' @param actor_id (numeric) The integer ID of the User.
#' @param old_password (character) The User's current password.
#' @param new_password (character) The new password the User wishes to set.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#directly-updating-a-user-password}
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
#' user_update_password(
#'   actor_id = ul$id[[1]],
#'   old_password = "old.password",
#'   new_password = "new.password"
#' )
#' # > $success
#' # > [1] TRUE
#' }
user_update_password <- function(
  actor_id,
  old_password,
  new_password,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)

  if (missing(actor_id) || length(actor_id) != 1L || is.na(actor_id)) {
    ru_msg_abort("actor_id must be a single Actor ID.")
  }
  for (arg in c("old_password", "new_password")) {
    val <- get(arg)
    if (!is.character(val) || length(val) != 1L || is.na(val) || !nzchar(val)) {
      ru_msg_abort(glue::glue("{arg} must be a single non-empty string."))
    }
  }

  ru_http_request(
    "PUT",
    url,
    path = glue::glue("v1/users/{actor_id}/password"),
    un = un,
    pw = pw,
    body = list(old = old_password, new = new_password),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("user_update_password")  # nolint
