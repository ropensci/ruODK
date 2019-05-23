#' Retrieve metadata from an OData URL ending in .svc as list of lists
#'
#' @param url The OData URL, ending in .svc, no trailing slash
#' @param un The ODK Central username (an email address),
#'           default: Sys.getenv("ODKC_UN").
#'           Add to your ~/.Rprofile: Sys.setenv(ODKC_UN="...@...")
#' @param pw The ODK Central password,,
#'           default: Sys.getenv("ODKC_PW").
#'           Add to your ~/.Rprofile: Sys.setenv(ODKC_PW="...")
#' @return A list of two named lists, DataServices and .attrs (Version). DataServices contains the dataset definition.
#' @importFrom XML xmlParse xmlToList
#' @importFrom httr add_headers authenticate content GET
#' @import magrittr
#' @export
get_metadata <- function(
                         url,
                         un = Sys.getenv("ODKC_UN"),
                         pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue("{url}/$metadata") %>%
    httr::GET(
      httr::add_headers(Accept = "application/xml"),
      httr::authenticate(un, pw)
    ) %>%
    httr::content(.) %>%
    XML::xmlParse(.) %>%
    XML::xmlToList(.)
}
