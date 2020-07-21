#' Parse a form_schema into a tibble of fields with name, type, and path.
#'
#' \lifecycle{stable}
#'
#' This function is used by \code{\link{form_schema}} for older versions of
#' ODK Central (pre 0.8). These return the form schema as XML, requiring the
#' quite involved code of \code{\link{form_schema_parse}}, while newer ODK
#' Central versions return JSON, which is parsed directly in
#' \code{\link{form_schema}}.
#'
#' The `form_schema` returned from ODK Central versions < 0.8 is a nested list
#' of lists containing the form definition.
#' The form definition consists of fields (with a type and name), and form
#' groups, which are rendered as separate ODK Collect screens.
#' Form groups in turn can also contain form fields.
#'
#' \code{\link{form_schema_parse}} recursively unpacks the form and extracts the
#' name and type of each field. This information then informs
#' \code{\link{handle_ru_attachments}}, \code{\link{handle_ru_datetimes}},
#' \code{\link{handle_ru_geopoints}}, \code{\link{handle_ru_geotraces}}, and
#' \code{\link{handle_ru_geoshapes}}.
#'
#' @param fs The output of form_schema as nested list
#' @param path The base path for form fields. Default: "Submissions".
#'   \code{\link{form_schema_parse}} recursively steps into deeper nesting
#'   levels, which are reflected as separate OData tables.
#'   The returned value in `path` reflects the XForms group name, which
#'   translates to separate screens in ODK Collect.
#'   Non-repeating form groups will be flattened out into the main Submissions
#'   table. Repeating groups are available as separate OData tables.
#' @template param-verbose
#' @family utilities
#' @export
#' @examples
#' \dontrun{
#' # Option 1: in two steps, ODKC Version 0.7
#' fs <- form_schema(flatten = FALSE, parse = FALSE, odkc_version = 0.7)
#' fsp <- form_schema_parse(fs)
#'
#' # Option 2: in one go
#' fsp <- form_schema(parse = TRUE)
#'
#' fsp
#' }
form_schema_parse <- function(fs,
                              path = "Submissions",
                              verbose = get_ru_verbose()) {
  # nolint start
  # 0. Recursion airbag
  # if (!(is.list(fs))) {ru_msg_info(glue::glue("Not a list:")); print(fs)}

  # 1. Grab next level type/name pairs, append column "path".
  # This does not work recursively - if it did, we'd be done here.
  # nolint end
  x <- fs %>%
    tibble::tibble(xx = .) %>%
    tidyr::unnest_wider(xx) %>%
    dplyr::select("type", "name") %>%
    dplyr::mutate(path = path)

  if (verbose == TRUE) {
    ru_msg_info(glue::glue("Found fields:"))
    print(x)
  }

  # 2. Recursively run form_schema_parse over nested elements.
  for (node in fs) {
    # Recursion seatbelt: only step into lists containing "children".
    if (is.list(node) && "children" %in% names(node)) {
      for (child in node["children"]) {
        odata_table_path <- glue::glue("{path}.{node['name']}")
        if (verbose == TRUE) {
          ru_msg_info(
            glue::glue("Found child: {child} at {odata_table_path}\n\n")
          )
        }
        xxx <- form_schema_parse(child, path = odata_table_path)
        x <- rbind(x, xxx)
      }
    }
  }

  # 3. Return combined type/name pairs as tibble
  if (verbose == TRUE) ru_msg_info(glue::glue("Returning data \"{str(x)}\""))

  # 4. Predict ruodk_name happens in form_schema
  x %>% tibble::as_tibble()
}

#' Predict a field name after \code{tidyr::unnest_wider(names_sep="_")} prefixes
#' the form path.
#'
#' @param name_str An Xforms field name string.
#' @param path_str A path string,
#'   e.g. "Submissions" or "Submissions.group_name".
#' @return The name as built by \code{tidyr::unnest_wider(names_sep="_")}.
#' @family utilities
#' @keywords internal
#' @examples
#' \dontrun{
#' predict_ruodk_name("bar", "Submissions.foo")
#' # > "foo_bar"
#' predict_ruodk_name("bar", "Submissions")
#' # > "bar"
#' predict_ruodk_name("rock", "Submissions.foo_fighters")
#' # > "foo_fighters_rock"
#' }
predict_ruodk_name <- function(name_str, path_str) {
  prefix <- path_str %>%
    stringr::str_remove("Submissions") %>%
    stringr::str_remove(".")
  sep <- ifelse(prefix == "", "", "_") # nolint
  glue::glue("{prefix}{sep}{name_str}") %>% as.character()
}

# usethis::edit_file("tests/testthat/test-form_schema_parse.R") # nolint
