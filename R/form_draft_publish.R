#' Publish a Draft Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This publishes the current Draft Form and makes it the active Form
#' definition (and attachments).
#' If the Draft version conflicts with an older version of the Form, the
#' publish operation fails, unless the new version string is given with
#' `version` and Central sets it on publish.
#' Once the Draft is published, there is no longer a Draft version of
#' the Form.
#' Publishing a Draft Form that defines a Dataset schema also publishes
#' the Dataset.
#'
#' @template param-pid
#' @template param-fid
#' @param version (character) The version to associate with the Draft
#'   once it is published.
#'   Default: `NULL` (the Draft keeps its version).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#publishing-a-draft-form}
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
#' form_draft_publish(fid = fl$fid[[1]], version = "2")
#' # > $success
#' # > [1] TRUE
#' }
form_draft_publish <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  version = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  query <- list()
  if (!is.null(version)) {
    if (
      !is.character(version) ||
        length(version) != 1L ||
        is.na(version) ||
        !nzchar(version)
    ) {
      ru_msg_abort("version must be a single non-empty character string.")
    }
    query$version <- version
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/draft/publish"
    ),
    query = query,
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("form_draft_publish")  # nolint
