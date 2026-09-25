#' Modify a Form's state.
#'
#' `r lifecycle::badge("experimental")`
#'
#' It is currently possible to modify only one thing about a Form:
#' its state, which governs whether it is available for download onto
#' survey clients and whether it accepts new Submissions.
#'
#' Only the properties you supply are changed.
#' Anything you do not supply remains untouched.
#' This changes only the `state`.
#' It does not change other properties.
#'
#' @template param-pid
#' @template param-fid
#' @param state (character) The new lifecycle state of the Form.
#'   One of `"open"`, `"closing"` or `"closed"`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A list with the updated Form's metadata as per the ODK Central
#'   API docs.
#'   Top level list elements are renamed from ODK's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#modifying-a-form}
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
#' f <- form_update(fid = fl$fid[[1]], state = "closing")
#'
#' f$state
#' # > "closing"
#' }
form_update <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  state = "",
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  if (
    !is.character(state) ||
      length(state) != 1L ||
      is.na(state) ||
      !(state %in% c("open", "closing", "closed"))
  ) {
    ru_msg_abort("state must be one of 'open', 'closing' or 'closed'.")
  }

  ru_http_request(
    "PATCH",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}"
    ),
    un = un,
    pw = pw,
    body = list(state = state),
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("form_update")  # nolint
