#' Get the GeoJSON of one Submission.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint returns the geodata of a single Submission in GeoJSON
#' format.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the GeoJSON `FeatureCollection` as returned by
#'   Central: `type` and `features` with `geometry` and `properties`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#retrieving-geojson-of-a-single-submission}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' sl <- submission_list()
#'
#' g <- submission_geojson(sl$instance_id[[1]])
#'
#' g$type
#' # > "FeatureCollection"
#' }
submission_geojson <- function(
  iid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}.geojson"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")
}

# usethis::use_test("submission_geojson")  # nolint
