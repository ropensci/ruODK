#' Delete a property from an Entity List.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Deletes a published Property from a Dataset.
#' The deletion is permanent, but a new Property with the same name can
#' be added again.
#' A Property cannot be deleted if any published or draft Forms write to
#' it, or if any Entities hold a non-empty value for it.
#' This endpoint requires ODK Central 2026.1 or later.
#'
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template param-pid
#' @template param-did
#' @param property (character) The name of the Property to delete.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-dataset-management/#deleting-a-property}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' entitylist_property_delete(did = "trees", property = "circumference")
#' # > $success
#' # > [1] TRUE
#' }
entitylist_property_delete <- function(
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

  if (odkc_version |> semver_lt("2026.1")) {
    ru_msg_warn("entitylist_property_delete is supported from v2026.1")
  }

  ru_http_request(
    "DELETE",
    url,
    path = glue::glue(
      "v1/projects/{pid}/datasets/",
      "{URLencode(did, reserved = TRUE)}/properties/",
      "{URLencode(property, reserved = TRUE)}"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("entitylist_property_delete")  # nolint
