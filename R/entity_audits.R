#' Return server audit logs of one Entity.
#'
#' `r lifecycle::badge("maturing")`
#'
#'
#' This returns
#' [Server Audit Logs](https://docs.getodk.org/central-api-system-endpoints/#server-audit-logs)
#' relating to an Entity. The most recent log is returned first.
#'
#' The authenticated user must have permissions on ODK Central to retrieve
#' audit logs.
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
#' @return A tibble with one row per audit log.
#'   See <https://docs.getodk.org/central-api-entity-management/#entity-audit-log>
#'   for the full schema.
#'   Top level list elements are renamed from ODK's `camelCase` to `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#entity-audit-log}
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
#' e_label <- ed$current_version$label
#'
#' # This example updates one field which exists in the example form.
#' # Your own Entity will have different fields to update.
#' e_data <- list(
#'   details = paste0(
#'     ed$current_version$data$details, ". Updated on ", Sys.time()
#'   )
#' )
#'
#' # Update the Entity (implicitly forced update)
#' eu <- entity_update(
#'   did = did,
#'   eid = en$uuid[1],
#'   label = e_label,
#'   data = e_data
#' )
#'
#' # Return the server audit logs
#' ea <- entity_audits(did = did, eid = en$uuid[1])
#' ea
#' }
entity_audits <- function(pid = get_default_pid(),
                            did = "",
                            eid = "",
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
    ru_msg_warn("entity_audits is supported from v2022.3")
  }

  pth <- glue::glue(
    "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/",
    "entities/{eid}/audits"
  )

  httr::RETRY(
    "GET",
    httr::modify_url(url, path = pth),
    httr::add_headers(
      "Accept" = "application/json",
      "X-Extended-Metadata" = "true"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    purrr::list_transpose() |>
    tibble::as_tibble(.name_repair = "universal") |>
    tidyr::unnest_wider("details", names_sep = "_") |>
    tidyr::unnest_wider("notes", names_sep = "_") |>
    tidyr::unnest_wider("actor", names_sep = "_") |>
    janitor::clean_names()
}

# usethis::use_test("entity_update")  # nolint
