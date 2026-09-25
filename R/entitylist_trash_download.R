#' Download Entities of a deleted Entity List.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Returns a CSV snapshot of the Entities belonging to a soft-deleted
#' Dataset.
#' This exports Entity data before the Dataset is permanently purged
#' after 30 days in the trash.
#' The CSV format is identical to `entitylist_download()`, except the
#' filename carries a `-deleted` suffix.
#' This endpoint uses the numeric Dataset ID rather than the Dataset
#' name, because the name alone cannot identify a deleted Dataset
#' unambiguously.
#' The numeric ID comes from listing Datasets with
#' `entitylist_list(deleted = TRUE)`.
#' This endpoint requires ODK Central 2026.1 or later.
#'
#' @template param-pid
#' @param dataset_id The numeric ID of the deleted Dataset, e.g. from
#'   `entitylist_list(deleted = TRUE)`.
#' @param local_dir The local folder to save the downloaded CSV to.
#'   If the folder does not exist it is created.
#'   Default: `tempdir()`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @template param-verbose
#' @return A list of three items:
#'   - entities (data.frame) The deleted Entities as parsed from CSV.
#'   - http_status (int) The HTTP status code of the response.
#'   - downloaded_to (fs_path) The path to the downloaded CSV file.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-dataset-management/#downloading-deleted-dataset-entities}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' trash <- entitylist_list(deleted = TRUE)
#'
#' dl <- entitylist_trash_download(dataset_id = trash$id[[1]])
#'
#' dl$entities |> knitr::kable()
#' }
entitylist_trash_download <- function(
  pid = get_default_pid(),
  dataset_id,
  local_dir = tempdir(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz(),
  verbose = get_ru_verbose()
) {
  yell_if_missing(url, un, pw, pid = pid)

  if (missing(dataset_id) || length(dataset_id) != 1L || is.na(dataset_id)) {
    ru_msg_abort("dataset_id must be a single Dataset ID.")
  }

  if (odkc_version |> semver_lt("2026.1")) {
    ru_msg_warn("entitylist_trash_download is supported from v2026.1")
  }

  if (!fs::dir_exists(local_dir)) {
    fs::dir_create(local_dir)
  }
  pth <- fs::path(local_dir, glue::glue("dataset-{dataset_id}-deleted.csv"))

  res <- ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/trash/datasets/{dataset_id}/entities.csv"
    ),
    accept = "text/csv; charset=utf-8",
    un = un,
    pw = pw,
    dest = pth,
    overwrite = TRUE,
    retries = retries
  )

  list(
    entities = httr::content(res, encoding = "utf-8"),
    http_status = res$status_code,
    downloaded_to = pth
  )
}

# usethis::use_test("entitylist_trash_download")  # nolint
