#' Restore a deleted Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Deleted Forms can be restored as long as they have been in the Trash
#' less than 30 days and have not been purged.
#' A deleted Form with the same `xmlFormId` as an active Form cannot be
#' restored while that other Form is active.
#' This function uses the numeric ID of the Form (returned by
#' `form_list(deleted = TRUE)`) rather than the `xmlFormId` to restore
#' unambiguously.
#' This endpoint requires ODK Central v1.4 or later.
#'
#' @template param-pid
#' @param id The numeric ID of the deleted Form, e.g. from
#'   `form_list(deleted = TRUE)`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#restoring-a-form}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' trash <- form_list(deleted = TRUE)
#'
#' form_restore(id = trash$id[[1]])
#' # > $success
#' # > [1] TRUE
#' }
form_restore <- function(
  pid = get_default_pid(),
  id,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid)

  if (missing(id) || length(id) != 1L || is.na(id)) {
    ru_msg_abort("id must be a single Form ID.")
  }

  httr::RETRY(
    "POST",
    httr::modify_url(
      url,
      path = glue::glue("v1/projects/{pid}/forms/{id}/restore")
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("form_restore")  # nolint
