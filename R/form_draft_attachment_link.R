#' Link a Dataset to a Draft Form attachment.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint updates a Form Attachment's link to a Dataset.
#' Linking only happens if the Attachment type is file and a Dataset
#' with the exact name of the Attachment (excluding the `.csv`
#' extension) exists in the Project.
#' Letter case and spaces must match exactly.
#' When a Dataset is linked, any attached file is removed.
#' This endpoint requires ODK Central v2022.3 or later.
#'
#' @template param-pid
#' @template param-fid
#' @param filename (character) The name of the attachment, e.g.
#'   `"people.csv"` for a Dataset named `"people"`.
#' @param dataset (lgl) Link (`TRUE`) or unlink (`FALSE`) the Dataset.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the updated attachment's metadata as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#linking-a-dataset-to-a-draft-form-attachment}
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
#' form_draft_attachment_link(fid = fid, filename = "people.csv", dataset = TRUE)
#' }
form_draft_attachment_link <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  filename,
  dataset = TRUE,
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
  if (!is.logical(dataset) || length(dataset) != 1L || is.na(dataset)) {
    ru_msg_abort("dataset must be TRUE or FALSE.")
  }

  ru_http_request(
    "PATCH",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/draft/attachments/",
      "{URLencode(filename, reserved = TRUE)}"
    ),
    un = un,
    pw = pw,
    body = list(dataset = dataset),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("form_draft_attachment_link")  # nolint
