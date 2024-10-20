#' Get the Service Document from the OData Dataset Service.
#'
#' `r lifecycle::badge("experimental")`
#'
#' ODK Central presents one OData service for every Dataset (Entity List)
#' as a way to get an OData feed of Entities.
#' To access the OData service, add `.svc` to the resource URL for the given
#' Dataset (Entity List).
#'
#' The Service Document provides a link to the main source of information
#' in this OData service: the list of Entities in this Dataset,
#' as well as the Metadata Document describing the schema of this information.
#'
#' This document is available only in JSON format.
#'
#' @template tpl-structure-nested
#' @template tpl-names-cleaned-top-level
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return An S3 class `odata_entitylist_service_get` with two list items:
#'  * `context` The URL for the OData metadata document
#'  * `value` A tibble of EntitySets available in this EntityList
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-odata-endpoints/#odata-dataset-service}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' ds <- entitylist_list(pid = get_default_pid())
#'
#' ds1 <- odata_entitylist_service_get(pid = get_default_pid(), did = ds$name[1])
#'
#' ds1
#' ds1$context
#' ds1$value
#' }
odata_entitylist_service_get <- function(pid = get_default_pid(),
                                         did = "",
                                         url = get_default_url(),
                                         un = get_default_un(),
                                         pw = get_default_pw(),
                                         retries = get_retries(),
                                         odkc_version = get_default_odkc_version(),
                                         orders = get_default_orders(),
                                         tz = get_default_tz()) {
  yell_if_missing(url, un, pw, pid = pid, did = did)

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("odata_entitylist_service_get is supported from v2022.3")
  }

  ds <- httr::RETRY(
    "GET",
    httr::modify_url(url,
      path = glue::glue(
        "v1/projects/{pid}/datasets/",
        "{URLencode(did, reserved = TRUE)}.svc"
      )
    ),
    httr::add_headers(
      "Accept" = "application/json"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()

  structure(list(
    context = ds$odata_context,
    value = purrr::map_df(ds$value, ~ tibble::as_tibble(.x))
  ), class = "odata_entitylist_service_get")
}

#' @export
print.odata_entitylist_service_get <- function(x, ...) {
  cat("<ruODK OData EntityList Service>", sep = "\n")
  cat("  OData Context: ", x$context, "\n")
  cat("  OData Entities:", nrow(x$value), "\n")
}

# usethis::use_test("odata_entitylist_service_get") # nolint
