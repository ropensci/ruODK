#' Modify a Project.
#'
#' `r lifecycle::badge("experimental")`
#'
#' The Project name may be updated, as well as the Project description
#' and the archived flag.
#' By default, archived is not set, which is equivalent to false.
#' If archived is set to true, the Project will be sorted to the bottom
#' of the list, and in the web management application the Project will
#' become effectively read-only.
#' API write access is not affected.
#' Only the properties you supply are changed.
#' Anything you do not supply remains untouched.
#'
#' @template param-pid
#' @param name (character) The desired name of the Project.
#'   Default: `NULL` (unchanged).
#' @param description (character) The desired description of the Project.
#'   Default: `NULL` (unchanged).
#' @param archived (lgl) Archive the Project.
#'   Default: `NULL` (unchanged).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the updated Project's metadata
#'   as columns, as per the ODK Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#updating-project-details}
# nolint end
#' @family project-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' p <- project_create("Test Project")
#'
#' p <- project_update(pid = p$id, description = "A test project.")
#'
#' p$description
#' # > "A test project."
#' }
project_update <- function(
  pid = get_default_pid(),
  name = NULL,
  description = NULL,
  archived = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid)

  body <- list()
  if (!is.null(name)) {
    if (
      !is.character(name) ||
        length(name) != 1L ||
        is.na(name) ||
        !nzchar(name)
    ) {
      ru_msg_abort("name must be a single non-empty character string.")
    }
    body$name <- name
  }
  if (!is.null(description)) {
    if (!is.character(description) || length(description) != 1L) {
      ru_msg_abort("description must be a single character string.")
    }
    body$description <- description
  }
  if (!is.null(archived)) {
    if (!is.logical(archived) || length(archived) != 1L || is.na(archived)) {
      ru_msg_abort("archived must be TRUE or FALSE.")
    }
    body$archived <- archived
  }
  if (length(body) == 0L) {
    ru_msg_abort("Supply at least one of 'name', 'description' or 'archived'.")
  }

  resp <- ru_http_request(
    "PATCH",
    url,
    path = glue::glue("v1/projects/{pid}"),
    un = un,
    pw = pw,
    body = body,
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json()
  tibble::tibble(
    id = resp$id,
    name = resp$name,
    description = resp$description %||% NA_character_,
    archived = resp$archived %||% FALSE
  )
}

# usethis::use_test("project_update")  # nolint
