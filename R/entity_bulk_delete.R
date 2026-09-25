#' Delete multiple Entities at once.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint accepts an array of Entity UUIDs and performs
#' soft-deletion on all of them.
#'
#' @template tpl-structure-nested
#' @template tpl-names-cleaned-top-level
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @param eids (character) The UUIDs of the Entities to delete.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A list with a single element `count` holding the number of
#'   Entities that the bulk operation deleted or restored.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#bulk-deleting-entities}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' el <- entitylist_list()
#' did <- el$name[1]
#'
#' en <- entity_list(did = did)
#'
#' entity_bulk_delete(did = did, eids = en$uuid[1:2])
#' # > $count
#' # > [1] 2
#' }
entity_bulk_delete <- function(
  pid = get_default_pid(),
  did = "",
  eids = c(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid, did = did)

  if (!is.character(eids) || length(eids) < 1L || any(is.na(eids))) {
    ru_msg_abort("eids must be one or more Entity UUIDs.")
  }

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entity_bulk_delete is supported from v2022.3")
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue(
      "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/",
      "entities/bulk-delete"
    ),
    un = un,
    pw = pw,
    body = list(ids = as.list(eids)),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("entity_bulk_delete")  # nolint
