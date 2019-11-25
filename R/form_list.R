#' List all forms.
#'
#' \lifecycle{stable}
#'
#' @template param-pid
#' @template param-url
#' @template param-auth
#' @return A tibble with one row per form and all form metadata as columns.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/forms}
# nolint end
#' @family restful-api
#' @importFrom httr add_headers authenticate content GET
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = paste0(
#'     "https://sandbox.central.opendatakit.org/v1/projects/14/",
#'     "forms/build_Flora-Quadrat-0-2_1558575936.svc"
#'   ),
#'   un = "me@email.com",
#'   pw = "..."
#' )
#'
#' # With default pid
#' fl <- form_list()
#'
#' # With explicit pid
#' fl <- form_list(pid = 1)
#'
#' class(fl)
#' # > c("tbl_df", "tbl", "data.frame")
#' }
form_list <- function(pid = get_default_pid(),
                      url = get_default_url(),
                      un = get_default_un(),
                      pw = get_default_pw()) {
  yell_if_missing(url, un, pw, pid = pid)
  glue::glue("{url}/v1/projects/{pid}/forms") %>%
    httr::GET(
      httr::add_headers(
        "Accept" = "application/xml",
        "X-Extended-Metadata" = "true"
      ),
      httr::authenticate(un, pw)
    ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    {
      tibble::tibble(
        name = purrr::map_chr(., "name"),
        fid = purrr::map_chr(., "xmlFormId"),
        version = purrr::map_chr(., "version"),
        state = purrr::map_chr(., "state"),
        submissions = purrr::map_chr(., "submissions"),
        created_at = purrr::map_chr(., "createdAt", .default = NA) %>%
          isodt_to_local(),
        created_by_id = purrr::map_int(., c("createdBy", "id")),
        created_by = purrr::map_chr(., c("createdBy", "displayName")),
        updated_at = purrr::map_chr(., "updatedAt", .default = NA) %>%
          isodt_to_local(),
        last_submission = purrr::map_chr(., "lastSubmission", .default = NA) %>%
          isodt_to_local(),
        hash = purrr::map_chr(., "hash")
      )
    }
}

# Tests
# usethis::edit_file("tests/testthat/test-form_list.R")
