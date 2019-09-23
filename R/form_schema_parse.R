#' Parse a form_schema into a tibble of fields with name, type, and path.
#'
#' \lifecycle{maturing}
#'
#' The `form_schema` is a nested list of lists containing the form definition.
#' The form definition consists of fields (with a type and name), and form
#' groups, which are rendered as separate ODK Collect screens.
#' Form groups in turn can also contain form fields.
#'
#' \code{`form_schema_parse`} recursively unpacks the form and extracts the name
#' and type of each field. This information then can be used to inform the user
#' which columns require \code{`parse_datetime`}, \code{`attachment_get`}, or
#' \code{`attachment_link`}, respectively.
#'
#' @param fs The output of form_schema as nested list
#' @template param-verbose
#' @family restful-api
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
#' # Attachments: use \code{`attachment_get`} on each of
#' fsp %>% dplyr::filter(type == "binary")
#'
#' # dateYime: use \code{`parse_datetime`} on each of
#' fsp %>% dplyr::filter(type == "dateTime")
#'
#' # Point location: will be split into lat/lon/alt/acc
#' fsp %>% dplyr::filter(type == "geopoint")
#' }
form_schema_parse <- function(fs, verbose = FALSE) {
  # 0. Spray R CMD check with WD-40
  . <- NULL
  type <- NULL
  name <- NULL
  children <- NULL

  # 1. Grab next level type/name pairs.
  # This does not work recursively - if it did, we'd be done here.
  x <- rlist::list.select(fs, type, name) %>% rlist::list.stack(.)
  if (verbose == TRUE) message(glue::glue("\n\nFound fields:\n{str(x)}\n"))

  # 2. Recursively run form_schema_parse over nested elements.
  for (node in fs) {
    # Recursion seatbelt: only step into lists containing "children".
    if (is.list(node) && "children" %in% names(node)) {
      for (child in node) {
        if (verbose == TRUE) message(glue::glue("\n\nFound child: {child}\n"))
        xxx <- form_schema_parse(child)
        x <- rbind(x, xxx)
      }
    }
  }

  # 3. Return combined type/name pairs as tibble
  if (verbose == TRUE) message(glue::glue("Returning data {str(x)}"))
  x %>% tibble::as_tibble()
}

# Tests
# usethis::edit_file("tests/testthat/test-form_schema_parse.R")
