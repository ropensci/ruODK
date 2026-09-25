#' Get Entity geodata as GeoJSON.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint returns the geometry-interpretable value of the
#' geometry attribute of Entities of a Dataset, in GeoJSON format.
#' No particular ordering is implied.
#'
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
#' @return A list with the GeoJSON `FeatureCollection` as returned by
#'   Central: `type` and `features` with `geometry` and `properties`
#'   per Entity.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#entities-geodata}
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
#' g <- entity_geodata(did = el$name[1])
#'
#' g$type
#' # > "FeatureCollection"
#' }
entity_geodata <- function(
  pid = get_default_pid(),
  did = "",
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
    ru_msg_warn("entity_geodata is supported from v2022.3")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/datasets/",
      "{URLencode(did, reserved = TRUE)}/entities.geojson"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")
}

# usethis::use_test("entity_geodata")  # nolint
