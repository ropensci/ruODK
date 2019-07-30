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
#' # With default credentials, see vignette("setup")
#' fs_defaults <- form_schema(1, "build_xformsId")
#'
#' # With explicit credentials, see tests
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
#' class(fs_nested)
#' # > "list"
#'
#' fs_flattened
#' # > "list"
#'
#' # This assumes knowledge of that exact form being tested.
#' # First node: type "structure" (a field group) named "meta".
#' fs_nested[[1]]$type
#' # > "structure"
#'
#' fs_nested[[1]]$name
#' # > "meta"
#'
#' # The first node contains children, which means it's an Xform field group.
#' names(fs_nested[[1]])
#' # > "children" ...
#'
#' # Next node: a "meta" field of type "string" capturing the  "instanceId".
#' # First child node of "meta": type "string", name "instanceId".
#' fs_nested[[1]]$children[[1]]$type
#' # > "string"
#' fs_nested[[1]]$children[[1]]$name
#' # > "instanceID"
#'
#' # In the flattened version, the field's and it's ancestors' names are the
#' # components of "path".
#' fs_flattened[[1]]$path
#' # > "meta". "instanceId"
#'
#' fs_flattened[[1]]$type
#' # > "string"
#'
#' # Last node: a "meta" field capturing the datetime of form completion
#' fs_flattened[[length(fs_flattened)]]$type
#' # > "dateTime"
#' fs_nested[[length(fs_nested)]]$type
#' # > "dateTime"
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
      httr::add_headers("Accept" = "application/json"),
      httr::authenticate(un, pw)
    ) %>%
    httr::stop_for_status() %>%
    httr::content(.)
}
