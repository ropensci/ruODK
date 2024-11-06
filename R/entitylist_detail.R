#' Show Entity List details.
#'
#' `r lifecycle::badge("maturing")`
#'
#' @template tpl-structure-nested
#' @template tpl-names-cleaned-top-level
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A list of lists following the exact format and naming of the API
#'   response. Since this nested list is so deeply nested and irregularly shaped
#'   it is not trivial to rectangle the result into a tibble.
# nolint start
#' @seealso \url{ https://docs.getodk.org/central-api-dataset-management/#datasets}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' ds <- entitylist_list(pid = get_default_pid())
#'
#' ds1 <- entitylist_detail(pid = get_default_pid(), did = ds$name[1])
#'
#' ds1 |> listviewer::jsonedit()
#'
#' ds1$linked_forms |>
#'   purrr::list_transpose() |>
#'   tibble::as_tibble()
#'
#' ds1$source_forms |>
#'   purrr::list_transpose() |>
#'   tibble::as_tibble()
#'
#' ds1$properties |>
#'   purrr::list_transpose() |>
#'   tibble::as_tibble()
#' }
entitylist_detail <- function(pid = get_default_pid(),
                              did = "",
                              url = get_default_url(),
                              un = get_default_un(),
                              pw = get_default_pw(),
                              retries = get_retries(),
                              odkc_version = get_default_odkc_version(),
                              orders = get_default_orders(),
                              tz = get_default_tz()) {
  yell_if_missing(url, un, pw, pid = pid, did = did)

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entitylist_detail is supported from v2022.3")
  }

  httr::RETRY(
    "GET",
    httr::modify_url(url,
      path = glue::glue(
        "v1/projects/{pid}/datasets/",
        "{URLencode(did, reserved = TRUE)}"
      )
    ),
    httr::add_headers(
      "Accept" = "application/json"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("entitylist_detail") # nolint
