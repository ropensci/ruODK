#' Delete one Entity.
#'
#' `r lifecycle::badge("maturing")`
#'
#'
#' This function soft-deletes one Entity, , which means it is still in Central's
#' database and you can retrieve it via `entity_list(deleted=TRUE)`.
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
#' @return A list with the key "success" (lgl) indicating whether the entity
#'   was deleted.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#deleting-an-entity}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' el <- entitylist_list()
#'
#' # Entity List name (dataset ID, did)
#' did <- el$name[1]
#'
#' # All Entities of Entity List
#' en <- entity_list(did = did)
#'
#' # View details of one Entity
#' ed <- entity_detail(did = did, eid = en$uuid[1])
#'
#' # Delete the Entity
#' ed_deleted <- entity_delete(did = did, eid = ed$id)
#' }
entity_delete <- function(pid = get_default_pid(),
                          did = "",
                          eid = "",
                          url = get_default_url(),
                          un = get_default_un(),
                          pw = get_default_pw(),
                          retries = get_retries(),
                          odkc_version = get_default_odkc_version(),
                          orders = c(
                            "YmdHMS",
                            "YmdHMSz",
                            "Ymd HMS",
                            "Ymd HMSz",
                            "Ymd",
                            "ymd"
                          ),
                          tz = get_default_tz()) {
  yell_if_missing(url, un, pw, pid = pid, did = did, eid = eid)

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entity_detail is supported from v2022.3")
  }

  pth <- glue::glue(
    "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/entities/{eid}"
  )

  httr::RETRY(
    "DELETE",
    httr::modify_url(url, path = pth),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("entity_create")  # nolint
