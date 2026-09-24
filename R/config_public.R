#' Show publicly accessible server configuration.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint returns all server configuration that is publicly
#' accessible in a single object.
#' This endpoint does not require authentication.
#' The following configurations are publicly accessible: login-appearance,
#' logo and hero-image.
#' For configuration that stores binary data (e.g. logo), this endpoint
#' only returns metadata about the configuration.
#' This endpoint requires ODK Central 2026.1 or later.
#'
#' @template param-url
#' @param un (character) The ODK Central username.
#'   Optional: the endpoint needs no authentication.
#'   Default: `NULL` (anonymous).
#' @param pw (character) The ODK Central password.
#'   Optional: the endpoint needs no authentication.
#'   Default: `NULL` (anonymous).
#' @template param-retries
#' @return A list with the public server configuration as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-system-endpoints/#getting-all-public-configuration}
# nolint end
#' @family server-management
#' @export
#' @examples
#' \dontrun{
#' cfg <- config_public(url = "https://my.odkcentral.org")
#'
#' names(cfg)
#' }
config_public <- function(
  url = get_default_url(),
  un = NULL,
  pw = NULL,
  retries = get_retries()
) {
  if (is.null(url) || identical(url, "")) {
    ru_msg_abort("Missing ODK Central URL. ru_setup()?")
  }

  auth <- NULL
  if (!is.null(un) && !is.null(pw) && nzchar(un) && nzchar(pw)) {
    auth <- httr::authenticate(un, pw)
  }

  httr::RETRY(
    "GET",
    httr::modify_url(url, path = "v1/config/public"),
    httr::add_headers("Accept" = "application/json"),
    auth,
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")
}

# usethis::use_test("config_public")  # nolint
