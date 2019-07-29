#' Show the schema of one form.
#'
#'
#' See https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/'-individual-form/retrieving-form-schema-json
#'
#' @template param-pid
#' @template param-fid
#' @param flatten Whether to flatten the resulting list of lists (TRUE) or not
#'   (FALSE, default).
#' @template param-auth
#' @return A nested list containing the form definition.
#'   At the lowest nesting level, each form field consists of a list of two
#'   nodes, `name` (the underlying field name) and `type` (the Xform field
#'   type, as in "string", "select1", "geopoint", "binary" and so on).
#'   These fields are nested in lists of tuples `name` (the Xform screen name),
#'   `children` (the fields as described above), `type` ("structure" for non-
#'   repeating screens, "repeat" for repeating screens).
#'   A list with `name` "meta" may precede the structure, if several metadata
#'   fields are captured (e.g. "instanceId", form start datetimes etc.).
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @export
#' @examples
#' \dontrun{
#' fs_defaults <- form_schema(1, "build_xformsId")
#'
#' fs_nested <- form_schema(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   flatten = FALSE,
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#' listviewer::jsonedit(fs_nested)
#'
#' fs_flattened <- form_schema(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   flatten = TRUE,
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#' listviewer::jsonedit(fs_flattened)
#'
#' # form_schema returns a nested list. There's nothing to change about that.
#' testthat::expect_equal(class(fs_nested), "list")
#' testthat::expect_equal(class(fs_flattened), "list")
#' # This assumes knowledge of that exact form being tested.
#' # First node: type "structure" (a field group) named "meta".
#' testthat::expect_equal(fs_nested[[1]]$type, "structure")
#' testthat::expect_equal(fs_nested[[1]]$name, "meta")
#' # The fact it contains children confirms that this is a field group.
#' testthat::expect_true("children" %in% names(fs_nested[[1]]))
#'
#' # Next node: a "meta" field of type "string" capturing the  "instanceId".
#' # First child node of "meta": type "string", name "instanceId".
#' testthat::expect_equal(fs_nested[[1]]$children[[1]]$type, "string")
#' testthat::expect_equal(fs_nested[[1]]$children[[1]]$name, "instanceID")
#'
#' # In the flattened version, the field's and it's ancestors' names are the
#' # components of "path".
#' testthat::expect_equal(fs_flattened[[1]]$path[[1]], "meta")
#' testthat::expect_equal(fs_flattened[[1]]$path[[2]], "instanceID")
#' testthat::expect_equal(fs_flattened[[1]]$type, "string")
#'
#' # Last node: a "meta" field capturing the datetime of form completion
#' testthat::expect_equal(fs_flattened[[length(fs_flattened)]]$type, "dateTime")
#' testthat::expect_equal(fs_nested[[length(fs_nested)]]$type, "dateTime")
#' }
form_schema <- function(pid,
                        fid,
                        flatten = FALSE,
                        url = Sys.getenv("ODKC_URL"),
                        un = Sys.getenv("ODKC_UN"),
                        pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue(
    "{url}/v1/projects/{pid}/forms/",
    "{fid}.schema.json?flatten={flatten}"
  ) %>%
    httr::GET(
      httr::add_headers("Accept" = "application/xml"),
      httr::authenticate(un, pw)
    ) %>%
    httr::stop_for_status() %>%
    httr::content(.)
}
