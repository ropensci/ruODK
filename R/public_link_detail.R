#' Show details of one Public Access Link.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Returns the details of a single Public Access Link by its numeric
#' ID.
#'
#' @template param-pid
#' @template param-fid
#' @param link_id The numeric ID of the Link.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the Link's metadata as columns
#'   as per the ODK Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#getting-link-details}
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
#' pd <- public_link_detail(fid = fid, link_id = pl$id[[1]])
#'
#' pd |> knitr::kable()
#' }
public_link_detail <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  link_id,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (missing(link_id) || length(link_id) != 1L || is.na(link_id)) {
    ru_msg_abort("link_id must be a single Link ID.")
  }

  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/public-links/{link_id}"
      )
    ),
    httr::add_headers("Accept" = "application/json"),
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

# usethis::use_test("public_link_detail")  # nolint
