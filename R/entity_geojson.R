#' Get the GeoJSON of one Entity.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Returns the GeoJSON representation of an Entity's geometry attribute,
#' if available.
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
#' @return A list with the GeoJSON `FeatureCollection` holding the
#'   Entity's geometry.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-entity-management/#entity-geojson-representation}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' el <- entitylist_list()
#' did <- el$name[1]
#'
#' en <- entity_list(did = did)
#'
#' g <- entity_geojson(did = did, eid = en$uuid[1])
#'
#' g$type
#' # > "FeatureCollection"
#' }
entity_geojson <- function(
  pid = get_default_pid(),
  did = "",
  eid = "",
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid, did = did, eid = eid)

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entity_geojson is supported from v2022.3")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/datasets/{URLencode(did, reserved = TRUE)}/",
      "entities/{eid}/geojson"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")
}

# usethis::use_test("entity_geojson")  # nolint
