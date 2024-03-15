#' List all Entity Lists of one Project.
#'
#' While the API endpoint will return all Entity Lists for one Project,
#' \code{\link{entitylist_list}} will fail with incorrect or missing
#' authentication.
#'
#' An Entity List is a named collection of Entities that have the same properties.
#' An Entity List can be linked to Forms as Attachments.
#' This will make it available to clients as an automatically-updating CSV.
#'
#' ODK Central calls Entity Lists internally Datasets. `ruODK` chooses the term
#' Entity Lists as it is used in the ODK Central user interface and conveys
#' its relation to Entities better than the term Dataset.
#'
#' This function is supported from ODK Central v2022.3 and will warn if the
#' given odkc_version is lower.
#'
#' `r lifecycle::badge("maturing")`
#'
#' @template param-pid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A tibble with exactly one row for each dataset of the given project
#'   as per ODK Central API docs.
#'   Column names are renamed from ODK's `camelCase` to `snake_case`.
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
#' ds |> knitr::kable()
#' }
entitylist_list <- function(pid = get_default_pid(),
                            url = get_default_url(),
                            un = get_default_un(),
                            pw = get_default_pw(),
                            retries = get_retries(),
                            odkc_version = get_default_odkc_version(),
                            orders = c(
                              "YmdHMS",
                              "YmdHMSz",
                              "Ymd HMS",
                              "Ymd HMSz",
                              "Ymd",
                              "ymd"
                            ),
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
