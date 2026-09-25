#' Update Submission data.
#'
#' `r lifecycle::badge("experimental")`
#'
#' You can use this endpoint to submit updates to an existing Submission.
#' The `instanceID` submitted with the initial version of the Submission
#' is used permanently to reference that Submission logically, which is to
#' say the initial Submission and all its subsequent versions.
#' Each subsequent version also provides its own `instanceID`.
#'
#' To perform an update, provide in the Submission XML an additional
#' `deprecatedID` metadata node with the `instanceID` of the particular
#' and current Submission version you are replacing.
#' If the `deprecatedID` you give is anything other than the identifier of
#' the current version of the Submission at the time the server receives
#' it, Central answers 409.
#' `deprecatedID` must contain the current `instanceID`.
#' `submission_get()` returns the current `instanceID`.
#' The new version must have a new `instanceID`.
#'
#' The XML data you send replaces the existing data entirely.
#' All of the data must be present in the updated XML.
#'
#' When you create a new Submission version, any uploaded media files
#' attached to the current version that match expected attachment names
#' in the new version are automatically copied over to the new version.
#'
#' This endpoint requires ODK Central v1.2 or later.
#'
#' @template param-iid
#' @template param-pid
#' @template param-fid
#' @param xml (character) The complete new Submission XML as a single
#'   string, including the `deprecatedID` metadata node.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the updated Submission's metadata as per the ODK
#'   Central API docs.
#'   Top level list elements are renamed from ODK's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#updating-submission-data}
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
#' xml <- paste0(
#'   '<data id="simple" version="1">',
#'   "<meta>",
#'   "<instanceID>uuid:85cb9aff-005e-4edd-9739-dc9c1a829c45</instanceID>",
#'   "<deprecatedID>", iid, "</deprecatedID>",
#'   "</meta>",
#'   "<name>Jo updated</name>",
#'   "</data>"
#' )
#'
#' s <- submission_update(iid = iid, xml = xml)
#'
#' s$current_version$instanceId
#' # > "uuid:85cb9aff-005e-4edd-9739-dc9c1a829c45"
#' }
submission_update <- function(
  iid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  xml = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid, iid = iid)

  if (!is.character(xml) || length(xml) != 1L || is.na(xml) || !nzchar(xml)) {
    ru_msg_abort("xml must be a single non-empty character string.")
  }

  ru_http_request(
    "PUT",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/submissions/{iid}"
    ),
    headers = c("Content-Type" = "application/xml"),
    un = un,
    pw = pw,
    body = xml,
    encode = "raw",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr2::resp_body_json() |>
    janitor::clean_names()
}

# usethis::use_test("submission_update")  # nolint
