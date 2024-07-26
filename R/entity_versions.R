#' List versions of one Entity.
#'
#' `r lifecycle::badge("maturing")`
#'
#'
#' This returns the Entity metadata and data for every version of this Entity
#' in ascending creation order.
#'
#' The ODK Central endpoint supports retrieving extended metadata which this
#' function always returns.
#'
#' There is an optional query flag `relevantToConflict` that returns the subset
#' of past versions of an Entity that are relevant to the Entity's current
#' conflict. This includes the latest version, the base version, the previous
#' server version, and any other versions since the last time the Entity was
#' in a conflict-free state. If the Entity is not in conflict, zero versions
#' are returned.
#'
#' @template tpl-structure-nested
#' @template tpl-names-cleaned-top-level
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @template param-eid
#' @param conflict (lgl) Whether to return all versions (`FALSE`) or
#'   whether to returns the subset of past versions of an Entity that are
#'   relevant to the Entity's current conflict (`TRUE`).
#'   This includes the latest version, the base version, the previous
#'   server version, and any other versions since the last time the Entity was
#'   in a conflict-free state. If the Entity is not in conflict, zero versions
#'   are returned.
#'   Default: `FALSE` (return all versions)
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A tibble with one row per version. List columns contain unstructured
#'   data.
#'   See <https://docs.getodk.org/central-api-entity-management/#listing-versions>
#'   for the full schema.
#'   Top level list elements are renamed from ODK's `camelCase` to `snake_case`.
#'   Nested list elements have the original `camelCase`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#listing-versions}
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
#' ed <- entity_detail(did = did, eid = en$uuid[1])
#'
#' # The current version of the first Entity
#' ev <- en$current_version_version[1]
#' }
entity_versions <- function(pid = get_default_pid(),
                            did = "",
                            eid = "",
                            conflict = FALSE,
                            url = get_default_url(),
                            un = get_default_un(),
                            pw = get_default_pw(),
                            retries = get_retries(),
                            odkc_version = get_default_odkc_version(),
                            orders = get_default_orders(),
                            tz = get_default_tz()) {
  yell_if_missing(url,
    un,
    pw,
    pid = pid,
    did = did,
    eid = eid
  )

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entity_detail is supported from v2022.3")
  }

  pth <- glue::glue(
    "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/",
    "entities/{eid}/versions"
  )

  qry <- list(relevantToConflict = ifelse(conflict == TRUE, "True", "False"))

  httr::RETRY(
    "GET",
    httr::modify_url(url, path = pth),
    httr::add_headers(
      "Accept" = "application/json",
      "X-Extended-Metadata" = "true"
    ),
    httr::authenticate(un, pw),
    query = qry,
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    purrr::list_transpose() |>
    tibble::as_tibble(.name_repair = "universal") |>
    janitor::clean_names()
}

# usethis::use_test("entity_update")  # nolint
