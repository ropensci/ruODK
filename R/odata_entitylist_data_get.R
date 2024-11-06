#' Get the Data Document from the OData Dataset Service.
#'
#' `r lifecycle::badge("experimental")`
#'
#' All the Entities in a Dataset.
#'
#' The `$top` and `$skip` querystring parameters, specified by OData, apply limit
#' and offset operations to the data, respectively.
#'
#' The `$count` parameter, also an OData standard, will annotate the response
#' data with the total row count, regardless of the scoping requested by `$top`
#' and `$skip`.
#' If `$top` parameter is provided in the request then the response will include
#' `@odata.nextLink` that you can use as is to fetch the next set of data.
#' As of ODK Central v2023.4, `@odata.nextLink` contains a `$skiptoken`
#' (an opaque cursor) to better paginate around deleted Entities.
#'
#' The `$filter` querystring parameter can be used to filter certain data fields
#' in the system-level schema, but not the Dataset properties.
#' The operators `lt`, `le`, `eq`, `ne`, `ge`, `gt`, `not`, `and`, and `or`
#' and the built-in functions `now`, `year`, `month`, `day`, `hour`,
#' `minute`, `second` are supported.
#'
#' The fields you can query against are as follows:
#'
#' Entity Metadata:	`OData Field Name`
#' Entity Creator Actor ID:	`__system/creatorId`
#' Entity Timestamp:	`__system/createdAt`
#' Entity Update Timestamp:	`__system/updatedAt`
#' Entity Conflict:	`__system/conflict`
#'
#' Note that `createdAt` and `updatedAt` are time components.
#' This means that any comparisons you make need to account for the full time
#' of the entity. It might seem like `$filter=__system/createdAt le 2020-01-31`
#' would return all results on or before 31 Jan 2020, but in fact only entities
#' made before midnight of that day would be accepted.
#' To include all of the month of January, you need to filter by either
#' `$filter=__system/createdAt le 2020-01-31T23:59:59.999Z` or
#' `$filter=__system/createdAt lt 2020-02-01`.
#' Remember also that you can query by a specific timezone.
#'
#' Please see the OData documentation on `$filter`
#  nolint start
#' [operations](http://docs.oasis-open.org/odata/odata/v4.01/cs01/part1-protocol/odata-v4.01-cs01-part1-protocol.html#sec_BuiltinFilterOperations)
#' and [functions](http://docs.oasis-open.org/odata/odata/v4.01/cs01/part1-protocol/odata-v4.01-cs01-part1-protocol.html#sec_BuiltinQueryFunctions)
#  nolint end
#' for more information.
#'
#' The `$select` query parameter will return just the fields you specify and is
#' supported on `__id`, `__system`, `__system/creatorId`, `__system/createdAt`
#' and `__system/updatedAt`, as well as on user defined properties.
#'
#' The `$orderby` query parameter will return Entities sorted by different
#' fields, which come from the same list used by `$filter`, as noted above.
#' The order can be specified as ASC (ascending) or DESC (descending),
#' which are case-insensitive. Multiple sort expressions can be used together,
#' separated by commas,
#' e.g. `$orderby=__system/creatorId ASC, __system/conflict DESC`.
#'
#' As the vast majority of clients only support the JSON OData format,
#' that is the only format ODK Central offers.
#'
#' @template tpl-structure-nested
#' @template tpl-names-cleaned-top-level
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @param query An optional named list of query parameters, e.g.
#'   ```
#'   list(
#'     "$filter" = "__system/createdAt le 2024-11-05",
#'     "$orderby" = "__system/creatorId ASC, __system/conflict DESC",
#'     "$top" = "100",
#'     "$skip" = "3",
#'     "$count" = "true"
#'  )
#'  ```
#'  No validation is conducted by `ruODK` on the query list prior to
#'  passing it to ODK Central.
#'  If omitted, no filter query is sent.
#'  Note that the behaviour of this parameter differs from the implementation
#'  of `odata_submission_get()` in that `query` here accepts a list of all
#'  possible OData query parameters and `odata_submission_get()` offers
#'  individual function parameters matching supported OData query parameters.
#'  Default: `NULL`
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return An S3 class `odata_entitylist_data_get` with two list items:
#'  * `context` The URL for the OData metadata document
#'  * `value` A tibble of EntitySets available in this EntityList, with names
#'    cleaned by `janitor::clean_names()` and unnested list columns
#'    (`__system`).
#' @seealso \url{https://docs.getodk.org/central-api-odata-endpoints/#id3}
# nolint start
#' @seealso \url{http://docs.oasis-open.org/odata/odata/v4.01/odata-v4.01-part1-protocol.html#_Toc31358948}
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
#' ds1 <- odata_entitylist_data_get(pid = get_default_pid(), did = ds$name[1])
#'
#' ds1
#' ds1$context
#' ds1$value
#'
#' qry <- list(
#'   "$filter" = "__system/createdAt le 2024-11-05",
#'   "$orderby" = "__system/creatorId ASC, __system/conflict DESC",
#'   "$top" = "100",
#'   "$skip" = "3",
#'   "$count" = "true"
#' )
#' ds2 <- odata_entitylist_data_get(
#'   pid = get_default_pid(),
#'   did = ds$name[1],
#'   query = qry
#' )
#'
#' ds2
#' }
odata_entitylist_data_get <- function(pid = get_default_pid(),
                                      did = "",
                                      query = NULL,
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
        "{URLencode(did, reserved = TRUE)}.svc/Entities"
      ),
      query = query
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

  entities <- ds$value |>
    # Replace NULLs with NA in each list
    purrr::map(~ purrr::modify_if(.x, is.null, ~NA)) |>
    purrr::map_dfr(
      ~ {
        # Extract main fields excluding __system
        main_fields <- .x[!names(.x) %in% "__system"]

        # Extract system fields or empty list if NULL
        system_fields <- .x[["__system"]] %||% list()

        # Ensure any NULL fields within system are NA
        system_fields <- purrr::modify_if(system_fields, is.null, ~NA)

        # Combine main and system fields into a single tibble row
        tibble::as_tibble(c(main_fields, system_fields))
      }
    ) |>
    janitor::clean_names() |>
    # Remove duplicate rows by `id`
    dplyr::distinct(id, .keep_all = TRUE) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::matches("created_at|updated_at"),
        ~ isodt_to_local(., orders = orders, tz = tz)
      )
    )

  structure(
    list(context = ds$odata_context, value = entities),
    class = c("odata_entitylist_data_get", "list")
  )
}

#' @export
print.odata_entitylist_data_get <- function(x, ...) {
  cat("<ruODK OData EntityList Data>", sep = "\n")
  cat("  OData Context: ", x$context, "\n")
  cat("  OData Entities:", nrow(x$value), "\n")
}

# usethis::use_test("odata_entitylist_data_get") # nolint
