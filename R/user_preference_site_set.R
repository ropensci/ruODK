#' Set a sitewide preference of the authenticated User.
#'
#' `r lifecycle::badge("experimental")`
#'
#' The Central frontend uses this API to save various user preferences,
#' such as the sorting order of certain listings.
#' The preference value may be of any JSON-serializable type.
#'
#' @param name (character) The name of the preference.
#' @param value The preference value to store.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-accounts-and-users/#setting-a-sitewide-preference}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' user_preference_site_set(name = "projectSortMode", value = "latest")
#' # > $success
#' # > [1] TRUE
#' }
user_preference_site_set <- function(
  name,
  value,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)

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

  httr::RETRY(
    "PUT",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/user-preferences/site/",
        "{URLencode(name, reserved = TRUE)}"
      )
    ),
    httr::add_headers("Accept" = "application/json"),
    encode = "json",
    body = list(propertyValue = value),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("user_preference_site_set")  # nolint
