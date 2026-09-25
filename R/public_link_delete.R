#' Delete a Public Access Link.
#'
#' `r lifecycle::badge("experimental")`
#'
#' A DELETE to a Link resource removes the Link from the system
#' entirely.
#' To only revoke the Link's access and prevent future Submissions
#' without removing its record, terminate its session token instead.
#'
#' @template param-pid
#' @template param-fid
#' @param link_id The numeric ID of the Link.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#deleting-a-link}
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
#' pl <- public_link_create(fid = fid, display_name = "Temporary link")
#'
#' public_link_delete(fid = fid, link_id = pl$id)
#' # > $success
#' # > [1] TRUE
#' }
public_link_delete <- function(
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

  ru_http_request(
    "DELETE",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/public-links/{link_id}"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("public_link_delete")  # nolint
