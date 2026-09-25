#' Get the GeoJSON of one Submission version.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint returns the geodata of a single Submission version in
#' GeoJSON format.
#'
#' @template param-iid
#' @param vid (character) The `instanceID` of the particular version of
#'   this Submission, e.g. from `submission_versions()`.
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the GeoJSON `FeatureCollection` as returned by
#'   Central: `type` and `features` with `geometry` and `properties`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#getting-version-geojson}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' sl <- submission_list()
#' iid <- sl$instance_id[[1]]
#'
#' sv <- submission_versions(iid)
#'
#' g <- submission_version_geojson(iid, vid = sv$instance_id[[1]])
#'
#' g$type
#' # > "FeatureCollection"
#' }
submission_version_geojson <- function(
  iid,
  vid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  if (
    missing(vid) ||
      !is.character(vid) ||
      length(vid) != 1L ||
      is.na(vid) ||
      !nzchar(vid)
  ) {
    ru_msg_abort("vid must be a single non-empty character string.")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}/",
      "versions/{vid}.geojson"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")
}

# usethis::use_test("submission_version_geojson")  # nolint
