#' Show the schema of one form.
#'
#'
#' @param flatten Whether to flatten the resulting list of lists (TRUE) or not
#'   (FALSE, default).
#' @param odata Whether to sanitise the field names to match the way they will
#'   be outputted for OData. While the original field names as given in the
#'   XForms definition may be used as-is for CSV output, OData has some
#'   restrictions related to the domain-qualified identifier syntax it uses.
#'   Default: FALSE.
#' @template param-pid
#' @template param-fid
#' @template param-url
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
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/'-individual-form/retrieving-form-schema-json}
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-2_1558575936.svc",
#'   un = "me@email.com",
#'   pw = "..."
#' )
#'
#' # With explicit pid and fid
#' fs_defaults <- form_schema(pid = 1, fid = "build_xformsId")
#'
#' # With defaults
#' fs_nested <- form_schema(
#'   flatten = FALSE,
#'   odata = FALSE
#' )
#' listviewer::jsonedit(fs_nested)
#'
#' fs_flattened <- form_schema(
#'   flatten = TRUE,
#'   odata = FALSE
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
form_schema <- function(flatten = FALSE,
                        odata = FALSE,
                        pid = get_default_pid(),
                        fid = get_default_fid(),
                        url = get_default_url(),
                        un = get_default_un(),
                        pw = get_default_pw()) {
  . <- NULL
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}.schema.json") %>%
    httr::GET(
      httr::add_headers("Accept" = "application/json"),
      httr::authenticate(un, pw),
      query = list(flatten = flatten, odata = odata)
    ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.)
}

# Tests
# usethis::edit_file("tests/testthat/test-form_schema.R")
