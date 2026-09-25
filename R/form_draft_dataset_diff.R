#' Show Dataset changes of a Draft Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This endpoint reflects the change to a Dataset that takes effect once
#' the Form is published.
#' Like the published endpoint, it lists the Dataset name and
#' Properties, but it also includes the `isNew` flag on both the
#' Dataset and each individual Property.
#' This flag is true only if the Dataset or Property is new and
#' publishing the Draft Form creates it.
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with one entry per affected Dataset, each holding the
#'   Dataset `name`, its `isNew` flag, and its `properties` with
#'   `inForm` and `isNew` flags.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#draft-form-dataset-diff}
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
#' dd <- form_draft_dataset_diff(fid = fl$fid[[1]])
#'
#' dd |> listviewer::jsonedit()
#' }
form_draft_dataset_diff <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/draft/dataset-diff"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")
}

# usethis::use_test("form_draft_dataset_diff")  # nolint
