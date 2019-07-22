#' Show details for one form.
#'
#'
#' See https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/'-individual-form
#'
#' @template param-pid
#' @template param-fid
#' @template param-auth
#' @return A tibble with one row and all form metadata as columns.
#' @importFrom httr add_headers authenticate content GET
#' @importFrom glue glue
#' @importFrom readr parse_datetime
#' @export
form_detail <- function(pid,
                        fid,
                        url = Sys.getenv("ODKC_URL"),
                        un = Sys.getenv("ODKC_UN"),
                        pw = Sys.getenv("ODKC_PW")) {
  . <- NULL
  glue::glue("{url}/v1/projects/{pid}/forms/{fid}") %>%
    httr::GET(
      httr::add_headers(
        "Accept" = "application/xml",
        "X-Extended-Metadata" = "true"
      ),
      httr::authenticate(un, pw)
    ) %>%
    httr::stop_for_status() %>%
    httr::content(.) %>%
    {
      tibble::tibble(
        name = .$name,
        xmlFormId = .$xmlFormId,
        version = .$version,
        state = .$state,
        submissions = .$submissions,
        createdAt = .$createdAt,
        createdById = .$createdBy$id,
        createdBy = .$createdBy$displayName,
        updatedAt = ifelse(
          is.null(.$updatedAt),
          NA_character_,
          .$updatedAt
        ),
        lastSubmission = ifelse(
          is.null(.$lastSubmission),
          NA_character_,
          .$lastSubmission
        ),
        hash = .$hash,
        xml = .$xml
      )
    }
}
