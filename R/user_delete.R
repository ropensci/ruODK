#' Delete a User.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Upon User deletion, the account is removed and the User is logged out of
#' all existing sessions.
#' The User record remains on file within the database, so that when for
#' example information about the creator of a Form or Submission is
#' requested, basic details are still available on file.
#' A new User account may be created with the same email address as any
#' deleted account.
#'
#' @param actor_id (numeric) The integer ID of the User.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#deleting-a-user}
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
#' user_delete(actor_id = ul$id[[1]])
#' # > $success
#' # > [1] TRUE
#' }
user_delete <- function(
  actor_id,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)

  if (missing(actor_id) || length(actor_id) != 1L || is.na(actor_id)) {
    ru_msg_abort("actor_id must be a single Actor ID.")
  }

  ru_http_request(
    "DELETE",
    url,
    path = glue::glue("v1/users/{actor_id}"),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("user_delete")  # nolint
