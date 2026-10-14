#' List all Entities of a kind.
#'
#' `r lifecycle::badge("maturing")`
#'
#' This function returns a list of the Entities of a kind (belonging to an
#' Entity List or Dataset).
#' Please note that this endpoint only returns metadata of the Entities, not the
#' data. If you want to get the data of all Entities then please refer to the
#' OData Dataset Service.
#'
#' You can get only deleted Entities with `deleted=TRUE`.
#'
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @param deleted (lgl) Whether to get only deleted Entities (`TRUE`) or not
#'   (`FALSE`). Default: `FALSE`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A tibble with exactly one row for each Entity of the given project
#'   as per ODK Central API docs.
#'   Column names are renamed from ODK's `camelCase` to `snake_case`.
#'   An empty Dataset answers `[]`, which returns the documented columns
#'   with no rows.
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
#' # Entity List name (Dataset ID)
#' did <- el$name[1]
#'
#' # All Entities of Entity List
#' en <- entity_list(did = el$name[1])
#'
#' # The UUID of the first Entity
#' eid <- en$uuid[1]
#'
#' # The current version of the first Entity
#' ev <- en$current_version_version[1]
#' }
entity_list <- function(
  pid = get_default_pid(),
  did = "",
  deleted = FALSE,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid, did = did)

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entity_list is supported from v2022.3")
  }

  pth <- glue::glue(
    "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/entities"
  )

  qry <- NULL
  if (deleted == TRUE) {
    qry <- list(deleted = "true")
  }

  entities <- ru_http_request(
    "GET",
    url,
    path = pth,
    query = qry,
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json()

  # An empty Dataset answers `[]`. Return the documented columns with no
  # rows (see the entities-metadata docs), so downstream code (nrow(),
  # `$` access, dplyr::bind_rows()) keeps working. Column order and types
  # match the non-empty result below.
  if (length(entities) == 0L) {
    return(tibble::tibble(
      uuid = character(),
      creator_id = integer(),
      created_at = as.POSIXct(character(), tz = tz),
      updated_at = as.POSIXct(character(), tz = tz),
      deleted_at = as.POSIXct(character(), tz = tz),
      current_version_current = logical(),
      current_version_label = character(),
      current_version_creator_id = integer(),
      current_version_user_agent = character(),
      current_version_version = integer(),
      current_version_base_version = integer(),
      current_version_conflicting_properties = logical(),
      current_version_created_at = as.POSIXct(character(), tz = tz),
      current_version_branch_id = logical(),
      current_version_trunk_version = logical(),
      current_version_branch_base_version = logical()
    ))
  }

  entities |>
    purrr::list_transpose() |>
    tibble::as_tibble() |>
    janitor::clean_names() |>
    tidyr::unnest_wider("current_version", names_sep = "_") |>
    tidyr::unnest_wider("conflict", names_sep = "_") |>
    janitor::clean_names() |>
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("entity_list")  # nolint
