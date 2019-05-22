#' Retrieve /Submissions from an OData URL ending in .svc as list of lists
#'
#' @param url The OData URL, ending in .svc, no trailing slash
#' @param un The ODK Central username (an email address),
#'           default: Sys.getenv("ODKC_UN").
#'           Add to your ~/.Rprofile: Sys.setenv(ODKC_UN="...@...")
#' @param pw The ODK Central password,,
#'           default: Sys.getenv("ODKC_PW").
#'           Add to your ~/.Rprofile: Sys.setenv(ODKC_PW="...")
#' @importFrom glue glue
#' @importFrom httr add_headers authenticate content GET
#' @import magrittr
#' @export
#' @return A list of two named lists, value and context. `value` contains the submissions, which can be "rectangled" using `tidyr::unnest_wider("element_name")`. `context` is the URL of the metadata.
get_submissions <- function(
  url,
  un=Sys.getenv("ODKC_UN"),
  pw=Sys.getenv("ODKC_PW")
){
  . <- NULL
  glue::glue("{url}/Submissions") %>%
    httr::GET(
      httr::add_headers(Accept = "application/json"),
      httr::authenticate(un, pw)
    ) %>%
    httr::content(.)
}
