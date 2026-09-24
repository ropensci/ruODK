#' Clear a Draft Form attachment.
#'
#' `r lifecycle::badge("experimental")`
#'
#' A DELETE to a Draft attachment's endpoint clears the uploaded bytes
#' while the expected file slot remains listed.
#'
#' @template param-pid
#' @template param-fid
#' @param filename (character) The name of the expected file slot, as
#'   given by `form_draft_attachment_list()`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#clearing-a-draft-form-attachment}
# nolint end
#' @family form-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' fl <- form_list()
#' fid <- fl$fid[[1]]
#'
#' form_draft_attachment_delete(fid = fid, filename = "cities.csv")
#' # > $success
#' # > [1] TRUE
#' }
form_draft_attachment_delete <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  filename,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (
    missing(filename) ||
      !is.character(filename) ||
      length(filename) != 1L ||
      is.na(filename) ||
      !nzchar(filename)
  ) {
    ru_msg_abort("filename must be a single non-empty character string.")
  }

  httr::RETRY(
    "DELETE",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/draft/attachments/",
        "{URLencode(filename, reserved = TRUE)}"
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

# usethis::use_test("form_draft_attachment_delete")  # nolint
