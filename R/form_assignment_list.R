#' Summarize all Form Assignments of one Project.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This returns a summary of all Form-specific Assignments within the
#' Project in one transactional request.
#' Each Assignment carries the `xmlFormId` of the Form it is attached
#' to, as well as the `actor_id`/`role_id` pair.
#'
#' @template param-pid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble with one row per Form Assignment and the columns
#'   `actor_id`, `xml_form_id` and `role_id`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#seeing-all-form-assignments-within-a-project}
# nolint end
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' al <- form_assignment_list()
#'
#' al |> knitr::kable()
#' }
form_assignment_list <- function(
  pid = get_default_pid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
) {
  yell_if_missing(url, un, pw, pid = pid)

  ru_http_request(
    "GET",
    url,
    path = glue::glue("v1/projects/{pid}/assignments/forms"),
    un = un,
    pw = pw,
    retries = retries
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

# usethis::use_test("form_assignment_list")  # nolint
