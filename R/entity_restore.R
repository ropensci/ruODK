#' Restore a deleted Entity.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Entities that have been recently soft-deleted and not yet purged can
#' be restored with this endpoint.
#'
#' @template tpl-structure-nested
#' @template tpl-names-cleaned-top-level
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @template param-eid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#restoring-a-deleted-entity}
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
#' entity_delete(did = did, eid = en$uuid[1])
#'
#' entity_restore(did = did, eid = en$uuid[1])
#' # > $success
#' # > [1] TRUE
#' }
entity_restore <- function(
  pid = get_default_pid(),
  did = "",
  eid = "",
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid, did = did, eid = eid)

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entity_restore is supported from v2022.3")
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue(
      "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/",
      "entities/{eid}/restore"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("entity_restore")  # nolint
