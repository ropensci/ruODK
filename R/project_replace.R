#' Replace a Project.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint allows a deep update of Project metadata, Form metadata,
#' and Form Assignment metadata at once and transactionally using a
#' nested data format.
#' This function replaces the top-level Project metadata.
#' Each call sends the complete `name`, `description` and `archived`
#' flag.
#' Omitted Form detail is left as-is, but this function sends no Form
#' detail.
#' Form states and assignments need a direct call to the ODK Central
#' API.
#'
#' @template param-pid
#' @param name (character) The desired name of the Project.
#' @param description (character) The desired description of the Project.
#' @param archived (lgl) Archive the Project.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the replaced Project's metadata
#'   as columns, as per the ODK Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#deep-updating-project-and-form-details}
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
#' p <- project_replace(
#'   pid = p$id,
#'   name = "Renamed Project",
#'   description = "A test project.",
#'   archived = FALSE
#' )
#'
#' p$name
#' # > "Renamed Project"
#' }
project_replace <- function(
  pid = get_default_pid(),
  name,
  description = "",
  archived = FALSE,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid)

  if (
    missing(name) ||
      !is.character(name) ||
      length(name) != 1L ||
      is.na(name) ||
      !nzchar(name)
  ) {
    ru_msg_abort("name must be a single non-empty character string.")
  }
  if (
    !is.character(description) ||
      length(description) != 1L ||
      is.na(description)
  ) {
    ru_msg_abort("description must be a single character string.")
  }
  if (!is.logical(archived) || length(archived) != 1L || is.na(archived)) {
    ru_msg_abort("archived must be TRUE or FALSE.")
  }

  resp <- ru_http_request(
    "PUT",
    url,
    path = glue::glue("v1/projects/{pid}"),
    un = un,
    pw = pw,
    body = list(name = name, description = description, archived = archived),
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

# usethis::use_test("project_replace")  # nolint
