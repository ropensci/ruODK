#' List expected attachments of one Submission version.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This lists the expected Submission attachments for the given version,
#' along with a boolean flag telling whether the server holds a copy of
#' each expected file or not.
#'
#' @template param-iid
#' @param vid (character) The `instanceID` of the particular version of
#'   this Submission, e.g. from `submission_versions()`.
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row per expected attachment and the columns
#'   `name` and `exists`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#listing-version-expected-attachments}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' sl <- submission_list()
#' iid <- sl$instance_id[[1]]
#'
#' sv <- submission_versions(iid)
#'
#' al <- submission_version_attachment_list(iid, vid = sv$instance_id[[1]])
#'
#' al |> knitr::kable()
#' }
# nolint start
submission_version_attachment_list <- function(
  # nolint end
  iid,
  vid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  if (
    missing(vid) ||
      !is.character(vid) ||
      length(vid) != 1L ||
      is.na(vid) ||
      !nzchar(vid)
  ) {
    ru_msg_abort("vid must be a single non-empty character string.")
  }

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}/",
      "versions/{vid}/attachments"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    (\(resp) {
      tibble::tibble(
        name = purrr::map_chr(resp, "name"),
        exists = purrr::map_lgl(resp, "exists")
      )
    })()
}

# usethis::use_test("submission_version_attachment_list")  # nolint
