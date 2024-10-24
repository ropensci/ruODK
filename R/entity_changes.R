#' List changes to one Entity.
#'
#' `r lifecycle::badge("maturing")`
#'
#' This returns the changes, or edits, between different versions of an Entity.
#' These changes are returned as a list of lists.
#' Between two Entities, there is a list of objects representing how each
#' property changed. This change object contains the old and new values, as well
#' as the property name.
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
#' @return A tibble where rows correspond to each Entity update
#'   with three columns:
#'
#'   - `old` old value
#'   - `new` new value
#'   - `propertyName` name of changed entity property
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#getting-changes-between-versions}
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
#' ec <- entity_changes(did = did, eid = en$uuid[1])
#' ec
#' }
entity_changes <- function(pid = get_default_pid(),
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
    ru_msg_warn("entity_changes is supported from v2022.3")
  }

  pth <- glue::glue(
    "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/",
    "entities/{eid}/diffs"
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
    purrr::map_df(~ purrr::map_df(.x, ~ tibble::as_tibble(.x)))
}

# usethis::use_test("entity_update")  # nolint
