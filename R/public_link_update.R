#' Set Actor Property values on a Public Access Link.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Sets pre-registered Actor Property values on a Public Access Link.
#' The body holds a `properties` object mapping property names to
#' string values.
#' Unsetting a property needs a JSON null, which this function cannot
#' send.
#' Only set properties with this function.
#' This endpoint requires the `public_link.update` permission.
#'
#' @template param-pid
#' @template param-fid
#' @param link_id The numeric ID of the Link.
#' @param properties (list) A named list mapping Actor Property names to
#'   string values.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the updated Link's metadata as per the ODK Central
#'   API docs, including a `properties` object with all currently set
#'   property values.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#setting-actor-property-values-on-a-link}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' fl <- form_list()
#' fid <- fl$fid[[1]]
#'
#' pl <- public_link_list(fid = fid)
#'
#' public_link_update(
#'   fid = fid,
#'   link_id = pl$id[[1]],
#'   properties = list("region" = "North")
#' )
#' }
public_link_update <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  link_id,
  properties = list(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (missing(link_id) || length(link_id) != 1L || is.na(link_id)) {
    ru_msg_abort("link_id must be a single Link ID.")
  }
  if (
    !is.list(properties) ||
      is.null(names(properties)) ||
      any(!nzchar(names(properties))) ||
      !all(purrr::map_lgl(properties, is.character))
  ) {
    ru_msg_abort("properties must be a named list of character strings.")
  }

  ru_http_request(
    "PATCH",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/public-links/{link_id}"
    ),
    un = un,
    pw = pw,
    body = list(properties = properties),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("public_link_update")  # nolint
