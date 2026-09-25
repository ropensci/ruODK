#' Add a property to an Entity List.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Creates a new Property with a specified name in the Dataset.
#' The name of a Property is case-sensitive in that it will keep the
#' capitalization provided (e.g. "Firstname").
#' But Central will not allow another Property with the same name but
#' different capitalization to be created
#' (e.g. "FIRSTNAME" when "Firstname" already exists).
#' Property names follow the same rules as form field names (valid XML
#' identifiers) and cannot use the reserved names of name or label, or
#' begin with the reserved prefix `__`.
#'
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @param property (character) The desired name of the Property.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-dataset-management/#adding-properties}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' entitylist_property_create(did = "trees", property = "circumference")
#' # > $success
#' # > [1] TRUE
#' }
entitylist_property_create <- function(
  pid = get_default_pid(),
  did = "",
  property = "",
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid, did = did)

  if (
    !is.character(property) ||
      length(property) != 1L ||
      is.na(property) ||
      !nzchar(property)
  ) {
    ru_msg_abort("property must be a single non-empty character string.")
  }

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entitylist_property_create is supported from v2022.3")
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue(
      "v1/projects/{pid}/datasets/",
      "{URLencode(did, reserved = TRUE)}/properties"
    ),
    un = un,
    pw = pw,
    body = list(name = property),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("entitylist_property_create")  # nolint
