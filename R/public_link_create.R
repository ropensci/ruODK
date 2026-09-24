#' Create a Public Access Link for one Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' To create a new Public Access Link to a Form, send at least a
#' `display_name` for the resulting Actor.
#' Set `once` to `TRUE` for a link that each respondent can only fill
#' once.
#' This setting is enforced by Enketo using local device tracking.
#' An optional `properties` object sets pre-registered Actor Property
#' values on the Link at creation time.
#'
#' @template param-pid
#' @template param-fid
#' @param display_name (character) The name of the Link, for keeping
#'   track of.
#'   This name shows on the Central administration website but not to
#'   survey respondents.
#' @param once (lgl) Create an Enketo single-submission survey instead
#'   of a standard one.
#'   Default: `FALSE`.
#' @param properties (list) An optional named list mapping
#'   pre-registered Actor Property names to string values.
#'   Default: `NULL` (not sent).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the new Link's metadata as
#'   columns as per the ODK Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#creating-a-link}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' fl <- form_list()
#'
#' pl <- public_link_create(fid = fl$fid[[1]], display_name = "Survey link")
#'
#' pl$token
#' }
public_link_create <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  display_name,
  once = FALSE,
  properties = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (
    missing(display_name) ||
      !is.character(display_name) ||
      length(display_name) != 1L ||
      is.na(display_name) ||
      !nzchar(display_name)
  ) {
    ru_msg_abort("display_name must be a single non-empty character string.")
  }
  if (!is.logical(once) || length(once) != 1L || is.na(once)) {
    ru_msg_abort("once must be TRUE or FALSE.")
  }

  body <- list(displayName = display_name, once = once)
  if (!is.null(properties)) {
    body$properties <- properties
  }

  httr::RETRY(
    "POST",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/public-links"
      )
    ),
    httr::add_headers("Accept" = "application/json"),
    encode = "json",
    body = body,
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
        token = resp$token %||% NA_character_,
        once = resp$once %||% NA,
        created_at = resp$createdAt %||% NA_character_,
        updated_at = resp$updatedAt %||% NA_character_
      )
    })()
}

# usethis::use_test("public_link_create")  # nolint
