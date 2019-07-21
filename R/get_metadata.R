#' Retrieve metadata from an OData URL ending in .svc as list of lists
#'
#' @template param-pid
#' @template param-fid
#' @template param-auth
#' @return A list of two named lists, DataServices and .attrs (Version).
#'         DataServices contains the dataset definition.
#' @importFrom httr add_headers authenticate content GET
#' @importFrom xml2 as_list
#' @export
get_metadata <- function(pid,
                         fid,
                         url = Sys.getenv("ODKC_URL"),
                         un = Sys.getenv("ODKC_UN"),
                         pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}.svc/$metadata") %>%
    httr::GET(
      httr::add_headers(Accept = "application/xml"),
      httr::authenticate(un, pw)
    ) %>%
    httr::content(.) %>%
    xml2::as_list(.)
}
