#' Get Submissions geodata as GeoJSON.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint returns Submissions' geodata, one Form field per
#' Submission, in GeoJSON format.
#' If no particular field path is supplied, the first non-repeat
#' geopoint, geotrace or geoshape field is used.
#' No particular ordering is implied.
#' An OData-style `$filter` query filters the Submissions.
#'
#' @template param-pid
#' @template param-fid
#' @param filter (character) An OData-style `$filter` query to filter
#'   the Submissions by.
#'   Default: `NULL` (not sent).
#' @param limit (numeric) The maximum number of Submissions to extract
#'   geoinformation from.
#'   Default: `NULL` (not sent).
#' @param fieldpath (character) The field to extract geoinformation
#'   from.
#'   At most one field can be given.
#'   Default: `NULL` (the first geofield outside any repeat group).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the GeoJSON `FeatureCollection` as returned by
#'   Central: `type` and `features` with `geometry` and `properties`
#'   per Submission.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#retrieving-submissions-geodata}
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
#' g <- submission_geodata()
#'
#' g$type
#' # > "FeatureCollection"
#' }
submission_geodata <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  filter = NULL,
  limit = NULL,
  fieldpath = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  query <- list()
  if (!is.null(filter)) {
    query[["$filter"]] <- filter
  }
  if (!is.null(limit)) {
    query$limit <- limit
  }
  if (!is.null(fieldpath)) {
    query$fieldpath <- fieldpath
  }

  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/submissions.geojson"
      ),
      query = query
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")
}

# usethis::use_test("submission_geodata")  # nolint
