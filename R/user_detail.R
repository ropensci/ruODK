#' Show details of one User.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Supply the integer ID to get the User with that ID, or the text
#' `current` for the currently authenticated User.
#' With `current`, extended metadata can be requested: the verbs the
#' authenticated Actor can perform server-wide, and the User's
#' preferences.
#'
#' @param actor_id The integer ID of the User, or `"current"` for the
#'   authenticated User.
#'   Default: `"current"`.
#' @param extended (lgl) If `TRUE`, request extended metadata with the
#'   `X-Extended-Metadata` header.
#'   Only used with `actor_id = "current"`.
#'   Default: `FALSE`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the User's metadata as columns
#'   as per the ODK Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#getting-user-details}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' me <- user_detail()
#'
#' me$display_name
#' }
user_detail <- function(
  actor_id = "current",
  extended = FALSE,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)

  if (length(actor_id) != 1L || is.na(actor_id)) {
    ru_msg_abort("actor_id must be a single User ID or 'current'.")
  }
  if (!is.logical(extended) || length(extended) != 1L || is.na(extended)) {
    ru_msg_abort("extended must be TRUE or FALSE.")
  }
  if (isTRUE(extended) && !identical(as.character(actor_id), "current")) {
    ru_msg_abort("extended metadata needs actor_id 'current'.")
  }

  headers <- c("Accept" = "application/json")
  if (isTRUE(extended)) {
    headers <- c(headers, "X-Extended-Metadata" = "true")
  }

  httr::RETRY(
    "GET",
    httr::modify_url(url, path = glue::glue("v1/users/{actor_id}")),
    httr::add_headers(.headers = headers),
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

# usethis::use_test("user_detail")  # nolint
