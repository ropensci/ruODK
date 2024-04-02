#' Update one Entity.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint is used to update the label or the properties (passed as JSON
#' in the request body) of an Entity.
#' You only need to include the properties you wish to update.
#' To unset the value of any property, you can set it to empty string ("").
#' The label must be a non-empty string.
#' Setting a property to null will throw an error.
#' Attempting to update a property that doesn't exist in the Dataset will throw
#' an error.
#'
#' ## Specifying a base version
#' You must either provide a `base_version` or use `force=TRUE` query parameter.
#' You cannot cause a new Entity conflict via the API, which is why when
#' specifying `base_version`, it must match the current version of the Entity on
#' the server. This acts as a check to ensure you are not trying to update based
#' on stale data. If you wish to update the Entity regardless of the current
#' state, then you can use the force flag.
#'
#' ## Resolving a conflict
#' You can also use this endpoint to resolve an Entity conflict by passing
#' `resolve=true`, in which case providing `data` is optional.
#' When not providing new data, only the conflict status from
#' the Entity will be cleared and no new version will be created.
#' When providing data, the conflict will be cleared and an updated version of
#' the Entity will be added.
#'
#' @template tpl-structure-nested
#' @template tpl-names-cleaned-top-level
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @template param-eid
#' @param label (character) The Entity label which must be a non-empty string.
#'   Default: `""`.
#' @param data (list) A named list of Entity properties to update. See details.
#'   Default: `list()`.
#' @param base_version If given, must be the current version of the Entity on
#'   the server. Optional.
#' @param force (lgl) Whether to force an update. Defaults to be `FALSE` if a
#'   `base_version` is specified, else defaults to `TRUE`.
#'   Using `force=TRUE` and specifying a `base_version` will emit a warning.
#' @param resolve (lgl)
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A nested list identical to the return value of `entity_detail`.
#'   See <https://docs.getodk.org/central-api-entity-management/#updating-an-entity>
#'   for the full schema.
#'   Top level list elements are renamed from ODK's `camelCase` to `snake_case`.
#'   Nested list elements have the original `camelCase`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#updating-an-entity}
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
#' eu
#' }
entity_update <- function(pid = get_default_pid(),
                          did = "",
                          eid = "",
                          label = "",
                          data = list(),
                          base_version = NULL,
                          force = is.null(base_version),
                          resolve = FALSE,
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

  if (label == "") {
    ru_msg_abort("The Entity label must be given as a non-empty string.")
  }

  if (force == TRUE && !is.null(base_version)) {
    ru_msg_warn(
      glue::glue(
        "You have specified force=TRUE and provided a base_version ",
        "{base_version}. force=TRUE forces an update, while base_version is ",
        "used to check that you are updating the latest version on the server.",
        " Most use cases need only one of these two parameters."
      )
    )
  }

  force_val <- ifelse(force == TRUE, "true", "false")
  resolve_val <- ifelse(resolve == TRUE, "true", "false")

  pth <- glue::glue(
    "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/",
    "entities/{eid}?force={force_val}&resolve={resolve_val}"
  )

  if (!is.null(base_version)) {
    if (!is.integer(as.integer(base_version))) {
      ru_msg_abort("base_version must be an integer.")
    }
    pth <- glue::glue("{pth}&baseVersion={as.integer(base_version)}")
  }

  httr::RETRY(
    "PATCH",
    httr::modify_url(url, path = pth),
    httr::add_headers("Accept" = "application/json"),
    encode = "json",
    body = list(label = as.character(label), data = data),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    # purrr::list_transpose() |>
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

# usethis::use_test("entity_update")  # nolint
