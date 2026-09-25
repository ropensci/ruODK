#' Show Form details by Form Link ID.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Returns Form metadata for the provided Form Link ID without needing
#' the Project ID or Form ID.
#'
#' @param form_link_id (character) The Form Link ID, e.g. the Enketo ID
#'   of a published Form.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the Form's metadata as columns
#'   as per the ODK Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#getting-form-details-by-formlinkid}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' fl <- form_list()
#'
#' f <- form_link(form_link_id = fl$enketo_id[[1]])
#'
#' f$fid
#' }
form_link <- function(
  form_link_id,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw)

  if (
    missing(form_link_id) ||
      !is.character(form_link_id) ||
      length(form_link_id) != 1L ||
      is.na(form_link_id) ||
      !nzchar(form_link_id)
  ) {
    ru_msg_abort("form_link_id must be a single non-empty character string.")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue("v1/form-links/{form_link_id}/form"),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    (\(resp) {
      tibble::tibble(
        forms = if (is.null(names(resp))) resp else list(resp)
      )
    })() |>
    tidyr::unnest_wider("forms", names_repair = "universal") |>
    janitor::clean_names() |>
    dplyr::mutate(fid = xml_form_id)
}

# usethis::use_test("form_link")  # nolint
