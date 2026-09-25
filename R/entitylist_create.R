#' Create an Entity List.
#'
#' `r lifecycle::badge("experimental")`
#'
#' You can create a Dataset with a specific name within a Project.
#' This Dataset can then be populated with Entities via the API or via
#' Forms and Submissions, and then used by other Forms.
#' This endpoint allows a Dataset to be created programmatically
#' without an input form.
#'
#' The name of a Dataset is case-sensitive in that it will keep the
#' capitalization provided (e.g. "Trees").
#' But Central will not allow a second Dataset with the same name but
#' different capitalization to be created
#' (e.g. "trees" when "Trees" already exists).
#'
#' By default, the Dataset will have no properties, but each Entity will
#' have a label and a unique ID (uuid).
#'
#' This creates an empty Entity List.
#' Add properties with the Dataset properties endpoint.
#' Add Entities with `entity_create()`.
#' Or publish a Form that defines the Entity List schema.
#'
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @param name (character) The desired name of the Entity List.
#'   The name must follow the same rules as XML identifiers and must not
#'   start with `.` or `__`.
#' @param approval_required (lgl) Control whether a Submission should be
#'   approved before an Entity is created from it.
#'   Default: `FALSE`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A list of lists following the exact format and naming of the API
#'   response for `entitylist_detail`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-dataset-management/#creating-datasets}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' el <- entitylist_create(name = "Trees")
#'
#' el$approvalRequired
#' # > FALSE
#' }
entitylist_create <- function(
  pid = get_default_pid(),
  name = "",
  approval_required = FALSE,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid)

  if (
    !is.character(name) ||
      length(name) != 1L ||
      is.na(name) ||
      !nzchar(name)
  ) {
    ru_msg_abort("name must be a single non-empty character string.")
  }
  if (startsWith(name, ".") || startsWith(name, "__")) {
    ru_msg_abort("name must not start with '.' or '__'.")
  }

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entitylist_create is supported from v2022.3")
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue("v1/projects/{pid}/datasets"),
    un = un,
    pw = pw,
    body = list(name = name, approvalRequired = approval_required),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("entitylist_create")  # nolint
