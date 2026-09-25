#' List all Public Access Links of one Form.
#'
#' `r lifecycle::badge("experimental")`
#'
#' This lists every Public Access Link upon the given Form.
#' Anybody in possession of a Public Access Link for a Form can use that
#' link to submit data to that Form.
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-orders
#' @template param-tz
#' @return A tibble with one row per Public Access Link and all Link
#'   metadata as columns as per the ODK Central API docs.
#'   Column names are renamed from ODK Central's `camelCase` to
#'   `snake_case`.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-form-management/#listing-all-links}
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
#' pl <- public_link_list(fid = fl$fid[[1]])
#'
#' pl |> knitr::kable()
#' }
public_link_list <- function(
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

  resp <- ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/",
      "{URLencode(fid, reserved = TRUE)}/public-links"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")

  tibble::tibble(links = resp) |>
    tidyr::unnest_wider("links", names_repair = "universal") |>
    janitor::clean_names() |>
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")),
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("public_link_list")  # nolint
