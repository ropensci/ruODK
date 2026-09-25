#' Show details of one published Form version.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Since the XForms specification allows blank strings as versions (and
#' Central treats the lack of a version as a blank string), pass the
#' special value `___` (three underscores) as the version to retrieve
#' the blank version.
#'
#' @template param-pid
#' @template param-fid
#' @param version (character) The version of the Form version being
#'   referenced.
#'   Pass `___` for a blank version.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row holding the Form version's metadata as
#'   columns as per the ODK Central API docs.
#'   Column names are renamed from ODK Central's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#getting-form-version-details}
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
#' vl <- form_version_list(fid = fid)
#'
#' vd <- form_version_detail(fid = fid, version = vl$version[[1]])
#'
#' vd |> knitr::kable()
#' }
form_version_detail <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  version,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (
    missing(version) ||
      !is.character(version) ||
      length(version) != 1L ||
      is.na(version) ||
      !nzchar(version)
  ) {
    ru_msg_abort("version must be a single non-empty character string.")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/versions/",
      "{URLencode(version, reserved = TRUE)}"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    (\(resp) {
      tibble::tibble(
        project_id = resp$projectId,
        fid = resp$xmlFormId,
        name = resp$name %||% NA_character_,
        version = resp$version %||% NA_character_,
        state = resp$state %||% NA_character_,
        hash = resp$hash %||% NA_character_,
        published_at = resp$publishedAt %||% NA_character_,
        created_at = resp$createdAt %||% NA_character_,
        updated_at = resp$updatedAt %||% NA_character_
      )
    })()
}

# usethis::use_test("form_version_detail")  # nolint
