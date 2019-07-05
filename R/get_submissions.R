#' Retrieve /Submissions from an OData URL ending in .svc as list of lists
#'
#' @template param-pid
#' @template param-fid
#' @param sub The submission EntityType name,
#'            default: "Submissions" (the main form).
#'            Change to "Submissions.GROUP_NAME" for repeating form groups.
#'            The group name can be found in the metadata under
#'            DataServices.Schema.[EntityType].Name
#' @template param-auth
#' @importFrom glue glue
#' @importFrom httr add_headers authenticate content GET
#' @import magrittr
#' @export
#' @return A list of two named lists, value and context. `value` contains
#' the submissions, which can be "rectangled" using
#' `tidyr::unnest_wider("element_name")`.
#' `context` is the URL of the metadata.
get_submissions <- function(pid,
                            fid,
                            sub = "Submissions",
                            url = Sys.getenv("ODKC_URL"),
                            un = Sys.getenv("ODKC_UN"),
                            pw = Sys.getenv("ODKC_PW")) {
  . <- NULL # Silence R CMD check
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}.svc/{sub}") %>%
    httr::GET(
      httr::add_headers(Accept = "application/json"),
      httr::authenticate(un, pw)
    ) %>%
    httr::content(.)
}
