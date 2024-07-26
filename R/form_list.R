#' List all forms.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-pid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-orders
#' @template param-tz
#' @return A tibble with one row per form and all given form metadata as cols.
#'   Column names are sanitized into `snake_case`.
#'   Nested columns (review start and created by) are flattened and prefixed.
#'   The column `xml_form_id` is replicated as `fid` according to `ruODK` naming
#'   standards.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#list-all-forms}
# nolint end
#' @family form-management
#' @importFrom httr add_headers authenticate content GET
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' # With default pid
#' fl <- form_list()
#'
#' # With explicit pid
#' fl <- form_list(pid = 1)
#'
#' class(fl)
#' # > c("tbl_df", "tbl", "data.frame")
#'
#' # Filter out draft forms (published_at=NA)
#' only_published_forms <- fl %>% dplyr::filter(is.na(published_at))
#'
#' # Note: older ODK Central versions < 1.1 have published_at = NA for both
#' # published and draft forms. Drafts have NA for version and hash.
#' only_published_forms <- fl %>% dplyr::filter(is.na(version) & is.na(hash))
#' }
form_list <- function(pid = get_default_pid(),
                      url = get_default_url(),
                      un = get_default_un(),
                      pw = get_default_pw(),
                      retries = get_retries(),
                      orders = get_default_orders(),
                      tz = get_default_tz()) {
  yell_if_missing(url, un, pw, pid = pid)
  httr::RETRY(
    "GET",
    httr::modify_url(url, path = glue::glue("v1/projects/{pid}/forms")),
    httr::add_headers(
      "Accept" = "application/xml",
      "X-Extended-Metadata" = "true"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    tibble::tibble(.) %>%
    tidyr::unnest_wider(".", names_repair = "universal") %>%
    {
      if ("reviewStates" %in% colnames(.)) {
        # nolint start
        # https://github.com/ropensci/ruODK/issues/145
        # Older Central versions have no variable reviewStates
        # nolint end
        tidyr::unnest_wider(
          .,
          "reviewStates",
          names_repair = "universal",
          names_sep = "_"
        )
      } else {
        .
      }
    } %>%
    tidyr::unnest_wider("createdBy",
      names_repair = "universal", names_sep = "_"
    ) %>%
    janitor::clean_names() %>%
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")),
      # assume datetimes are named "_at"
      ~ isodt_to_local(., orders = orders, tz = tz)
    ) %>%
    dplyr::mutate(fid = xml_form_id)
}

# usethis::use_test("form_list") # nolint
