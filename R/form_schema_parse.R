#' Parse a form_schema into a tibble of fields with name, type, and path.
#'
#' \lifecycle{maturing}
#'
#' The `form_schema` is a nested list of lists containing the form definition.
#' The form definition consists of fields (with a type and name), and form
#' groups, which are rendered as separate ODK Collect screens.
#' Form groups in turn can also contain form fields.
#'
#' \code{\link{form_schema_parse}} recursively unpacks the form and extracts the
#' name and type of each field. This information then can be used to inform the
#' user which columns require \code{\link{handle_ru_datetimes}},
#' \code{\link{attachment_get}}, or \code{\link{attachment_link}}, respectively.
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
#' # Option 1: in two steps
#' fs <- form_schema(flatten = FALSE) # Default, but shown for clarity
#' fsp <- form_schema_parse(fs)
#'
#' # Option 2: in one go
#' fsp <- form_schema(parse = TRUE)
#'
#' fsp
#'
#' # Attachments: use \\code{\\link{attachment_get}} on each of
#' fsp %>% dplyr::filter(type == "binary")
#'
#' # dateTime: use \\code{\\link{ru_datetime}} on each of
#' fsp %>% dplyr::filter(type == "dateTime")
#'
#' # Point location: will be split into lat/lon/alt/acc
#' fsp %>% dplyr::filter(type == "geopoint")
#' }
form_schema_parse <- function(fs,
                              path = "Submissions",
                              verbose = get_ru_verbose()) {
  # 0. Recursion airbag
  # if (!(is.list(fs))) {ru_msg_info(glue::glue("Not a list:")); print(fs)}

  # 1. Grab next level type/name pairs, append column "path".
  # This does not work recursively - if it did, we'd be done here.
  x <- fs %>%
    rlist::list.select(name, type) %>%
    rlist::list.stack(.) %>%
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
          ru_msg_info(glue::glue("Found child: {child} at {odata_table_path}"))
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
#' testthat::expect_equal(
#'   predict_ruodk_name("bar", "Submissions.foo"), "foo_bar"
#' )
#' testthat::expect_equal(
#'   predict_ruodk_name("bar", "Submissions"), "bar"
#' )
#' testthat::expect_equal(
#'   predict_ruodk_name("bar", "Submissions.foo_fighters"), "foo_fighters_bar"
#' )
predict_ruodk_name <- function(name_str, path_str) {
  prefix <- path_str %>%
    stringr::str_remove("Submissions") %>%
    stringr::str_remove(".")
  sep <- ifelse(prefix == "", "", "_")
  glue::glue("{prefix}{sep}{name_str}") %>% as.character()
}

# Tests
# usethis::edit_file("tests/testthat/test-form_schema_parse.R")
