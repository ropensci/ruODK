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
#' @examples
#' \dontrun{
#' # With default credentials, see vignette("setup")
#' fl <- form_list(1)
#'
#' # With explicit credentials, see tests
#' fl <- form_list(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#'
#' # The first form in the test project
#' f <- form_detail(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   fl$xmlFormId[[1]],
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#'
#' # form_detail returns exactly one row
#' nrow(f)
#' # > 1
#'
#' # form_detail returns all form metadata as columns: name, xmlFormId, etc.
#' names(f)
#' }
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
