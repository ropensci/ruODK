#' Show details of one Entity.
#'
#' `r lifecycle::badge("maturing")`
#'
#'
#' This function returns the metadata and current data of an Entity.
#'
#' The data and label of an Entity are found in the `current_version` columns
#' under data and label respectively.
#' The `current_version` column contains version-specific metadata fields
#' such as version, baseVersion, details about conflicts that version
#' introduced, etc. More details are available from `entity_versions()`.
#' The Entity also contains top-level system metadata such as `uuid`,
#' `created_at` and `updated_at` timestamps, and `creator_id` (or full creator
#' if extended metadata is requested).
#'
#' ## Conflicts
#' An Entity's metadata also has a conflict field, which indicates the current
#' conflict status of the Entity. The value of a conflict can either be:
#'
#' - null. The Entity does not have conflicting versions.
#' - soft. The Entity has a version that was based on a version other than the
#'   version immediately prior to it. (The specified `base_version` was not the
#'   latest version on the server.)
#' - hard. The Entity has a version that was based on a version other than the
#'   version immediately prior to it. Further, that version updated the same
#'   property as another update.
#'
#' If an Entity has a conflict, it can be marked as resolved.
#' After that, the conflict field will be null until a new conflicting version
#' is received.
#'
#' ## Structure
#' The response from ODK Central from this endpoint is irregular and dynamic.
#' `ruODK` preserves the original structure as not to introduce additional
#' complexity. If a use case exists to decompose the original structure further
#' please create a GitHub issue.
#'
#' ## Names
#' Names are cleaned at the top level only. List columns contain original
#' `camelCase` names.
#'
#' ## Authentication
#' `entity_detail()` will fail with incorrect or missing authentication.
#'
#' ## Compatibility
#' This function is supported from ODK Central v2022.3 and will warn if the
#' given `odkc_version` is lower.
#'
#' @template param-pid
#' @template param-did
#' @template param-eid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A tibble with exactly one row for each Entity of the given project
#'   as per ODK Central API docs.
#'   Column names are renamed from ODK's `camelCase` to `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#entities-metadata}
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
entity_detail <- function(pid = get_default_pid(),
                          did = NULL,
                          eid = NULL,
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
  yell_if_missing(url, un, pw, pid = pid)

  if (is.null(did)) {
    ru_msg_abort("entity_detail requires the Entity List name as 'did=\"name\"'.")
  }

  if (is.null(eid)) {
    ru_msg_abort("entity_detail requires the Entity UUID as 'eid=\"uuid\"'.")
  }

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entity_detail is supported from v2022.3")
  }

  pth <- glue::glue(
    "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/entities/{eid}"
  )

  httr::RETRY(
    "GET",
    httr::modify_url(url, path = pth),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    # purrr::list_transpose() |>
    #
    # tibble::enframe() |>
    # tibble::as_tibble(.name_repair = "universal") |>
    # tidyr::pivot_wider(names_from = "name", values_from = "value") |>
    # tidyr::unnest_wider("conflict", names_sep = "_") |>
    # janitor::clean_names() |>
    # tidyr::unnest_wider("current_version", names_sep = "_") |>
    janitor::clean_names()
  # dplyr::mutate_at(
  # dplyr::vars(dplyr::contains("_at")),
  # ~ isodt_to_local(., orders = orders, tz = tz)
  # )
}

# usethis::use_test("entity_detail")  # nolint
