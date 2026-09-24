#' List all published versions of one Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Each entry of the version listing contains some of the same duplicate
#' keys with basic information about the Form: `xmlFormId` and
#' `createdAt`, for example.
#' This matches the data received when each version is requested
#' separately.
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-orders
#' @template param-tz
#' @return A tibble with one row per published Form version and all
#'   version metadata as columns as per the ODK Central API docs.
#'   Column names are renamed from ODK Central's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#listing-published-form-versions}
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
#' vl <- form_version_list(fid = fl$fid[[1]])
#'
#' vl |> knitr::kable()
#' }
form_version_list <- function(
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)

  resp <- httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/versions"
      )
    ),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")

  tibble::tibble(versions = resp) |>
    tidyr::unnest_wider("versions", names_repair = "universal") |>
    janitor::clean_names() |>
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("form_version_list")  # nolint
