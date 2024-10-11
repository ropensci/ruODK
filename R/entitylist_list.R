#' List all Entity Lists of one Project.
#'
#' `r lifecycle::badge("maturing")`
#'
#' The returned list is useful to retrieve the valid name of an Entity List for
#' further use by functions of the Entity Management family.
#'
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A tibble with exactly one row for each Entity List of the given
#'   Project as per ODK Central API docs.
#'   Column names are renamed from ODK Central's `camelCase` to `snake_case`.
# nolint start
#' @seealso \url{ https://docs.getodk.org/central-api-dataset-management/#datasets}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "... .svc", un = "me@email.com", pw = "...")
#'
#' ds <- entitylist_list(pid = get_default_pid())
#'
#' ds |> knitr::kable()
#' }
entitylist_list <- function(pid = get_default_pid(),
                            url = get_default_url(),
                            un = get_default_un(),
                            pw = get_default_pw(),
                            retries = get_retries(),
                            odkc_version = get_default_odkc_version(),
                            orders = get_default_orders(),
                            tz = get_default_tz()) {
  yell_if_missing(url, un, pw, pid = pid)

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entitylist_list is supported from v2022.3")
  }

  httr::RETRY(
    "GET",
    httr::modify_url(url, path = glue::glue("v1/projects/{pid}/datasets")),
    httr::add_headers(
      "Accept" = "application/json",
      "X-Extended-Metadata" = "true"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    purrr::list_transpose() |>
    tibble::as_tibble() |>
    janitor::clean_names() |>
    dplyr::mutate_at(
      dplyr::vars(c("created_at", "last_entity")),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("entitylist_list") # nolint
