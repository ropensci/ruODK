#' Delete a Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' When a Form is deleted, it goes into the Trash section, but it can now be
#' restored from the Trash with `form_restore()`.
#' After 30 days in the Trash, the Form and all of its resources and
#' Submissions will be automatically purged.
#' If the goal is to prevent the Form from showing up on survey clients like
#' ODK Collect, consider setting its state to closing or closed instead
#' (see `form_update()`).
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#deleting-a-form}
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
#' form_delete(fid = fl$fid[[1]])
#' # > $success
#' # > [1] TRUE
#' }
form_delete <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  httr::RETRY(
    "DELETE",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}"
      )
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("form_delete")  # nolint
