#' List Role-specific Form Assignments within a Project.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Like the Form Assignments summary, but filtered by some Role.
#' Returned results include an `xmlFormId` field to specify which Form each
#' Assignment is attached to.
#' This endpoint requires ODK Central v0.7 or later.
#'
#' @template param-pid
#' @param role_id (numeric) The numeric ID of the Role.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @return A tibble with one row for each Form Assignment of the Role as per
#'   the ODK Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#seeing-role-specific-form-assignments-within-a-project}
# nolint end
#' @family project-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' fa <- form_assignment_role_list(role_id = 2)
#'
#' fa |> knitr::kable()
#' }
form_assignment_role_list <- function(
  pid = get_default_pid(),
  role_id,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version()
) {
  yell_if_missing(url, un, pw, pid = pid)

  if (odkc_version |> semver_lt("0.7")) {
    ru_msg_warn("form_assignment_role_list is supported from v0.7")
  }

  if (missing(role_id) || length(role_id) != 1L || is.na(role_id)) {
    ru_msg_abort("role_id must be a single Role ID.")
  }

  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue("v1/projects/{pid}/assignments/forms/{role_id}")
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    (\(resp) {
      tibble::tibble(
        actor_id = purrr::map_dbl(resp, "actorId"),
        xml_form_id = purrr::map_chr(resp, "xmlFormId"),
        role_id = purrr::map_dbl(resp, "roleId")
      )
    })()
}

# usethis::use_test("form_assignment_role_list")  # nolint
