#' Download an Entity List as CSV.
#'
#' `r lifecycle::badge("maturing")`
#'
#' ## CSV file
#' The downloaded CSV file is named after the Entity List name.
#' The download location defaults to the current workdir, but can be modified
#' to a different folder path which will be created if it doesn't exist.
#'
#' Entity Lists can be used as Attachments in other Forms, but they can also be
#' downloaded directly as a CSV file.
#'
#' The CSV format closely matches the OData Dataset (Entity List) Service
#' format, with columns for system properties such as `__id` (the Entity UUID),
#' `__createdAt`, `__creatorName`, etc., the Entity Label, and the
#' Dataset (Entity List) or Entity Properties themselves.
#' If any Property for an given Entity is blank (e.g. it was not captured by
#' that Form or was left blank), that field of the CSV is blank.
#'
#' ## Filter
#' The ODK Central `$filter` query string parameter can be used to filter on
#' system-level properties, similar to how filtering in the OData Dataset
#' (Entity List) Service works.
#' Of the [OData filter specs
#' ](https://docs.oasis-open.org/odata/odata/v4.01/odata-v4.01-part1-protocol.html#_Toc31358948)
#' ODK Central implements a [growing set of features
#' ](https://docs.getodk.org/central-api-odata-endpoints/#data-document).
#' `ruODK` provides the parameter `filter` (str) which, if set, will be passed
#' on to the ODK Central endpoint as is.
#'
#' ## Resuming downloads through ETag
#' The ODK Central endpoint supports the [`ETag` header
#' ](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag), which can
#' be used to avoid downloading the same content more than once.
#' When an API consumer calls this endpoint, the endpoint returns a value in
#' the `ETag` header.
#' If you pass that value in the [`If-None-Match` header
#' ](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None-Match)
#' of a subsequent request,
#' then if the Entity List has not been changed since the previous request,
#' you will receive 304 Not Modified response; otherwise you'll get the new
#' data.
#' `ruODK` provides the parameter `etag` which can be set from the output of
#' a previous call to `entitylist_download()`. `ruODK` strips the `W/\"` and
#' `\"` from the returned etag and expects the stripped etag as parameter.
#'
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @template param-url
#' @template param-auth
#' @param local_dir The local folder to save the downloaded files to,
#'   default: \code{here::here}.
#'   If the folder does not exist it will be created.
#' @param etag (str) The etag value from a previous call to
#'   `entitylist_download()`. The value must be stripped of the `W/\"` and `\"`,
#'   which is the format of the etag returned by `entitylist_download()`.
#'   If provided, only new Entities will be returned.
#'   If the same `local_dir` is chosen and `overwrite` is set to `TRUE`,
#'   the downloaded CSV will also be overwritten, losing the previously
#'   downloaded Entities.
#'   Default: NULL (no filtering, all Entities returned).
#' @param filter (str) A valid filter string.
#'   Default: NULL (no filtering, all Entities returned).
#' @param overwrite Whether to overwrite previously downloaded file,
#'                 default: FALSE
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @template param-verbose
#' @return A list of four items:
#'   - entities (tbl_df) The Entity List as tibble
#'   - http_status (int) The HTTP status code of the response.
#'     200 if OK, 304 if a given etag finds no new Entities created.
#'   - etag (str) The ETag to use in subsequent calls to `entitylist_download()`
#'   - downloaded_to (fs_path) The path to the downloaded CSV file
#'   - downloaded_on (POSIXct) The time of download in the local timezone
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-dataset-management/#datasets}
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
#' ds1 <- entitylist_download(pid = get_default_pid(), did = ds$name[1])
#' # ds1$entities
#' # ds1$etag
#' # ds1$downloaded_to
#' # ds1$downloaded_on
#'
#' ds2 <- entitylist_download(
#'   pid = get_default_pid(),
#'   did = ds$name[1],
#'   etag = ds1$etag
#' )
#' # ds2$http_status == 304
#'
#' newest_entity_date <- as.Date(max(ds1$entities$`__createdAt`))
#' ds3 <- entitylist_download(
#'   pid = get_default_pid(),
#'   did = ds$name[1],
#'   filter = glue::glue("__createdAt le {newest_entity_date}")
#' )
#' }
entitylist_download <- function(
  pid = get_default_pid(),
  did = "",
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  local_dir = here::here(),
  filter = NULL,
  etag = NULL,
  overwrite = TRUE,
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz(),
  verbose = get_ru_verbose()
) {
  # Gatecheck params
  yell_if_missing(url, un, pw, pid = pid, did = did)

  # Gatecheck ODKC version
  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entitylist_download is supported from v2022.3")
  }

  # Download file destination directory
  if (!fs::dir_exists(local_dir)) {
    fs::dir_create(local_dir)
  }

  # Downloaded file path
  pth <- fs::path(local_dir, glue::glue("{did}.csv"))

  # Emit message
  if (fs::file_exists(pth)) {
    if (overwrite == TRUE) {
      "Overwriting previous entity list: \"{pth}\"" |>
        glue::glue() |>
        ru_msg_success(verbose = verbose)
    } else {
      "Keeping previous entity list: \"{pth}\"" |>
        glue::glue() |>
        ru_msg_success(verbose = verbose)
    }
  } else {
    "Downloading entity list \"{did}\" to {pth}" |>
      glue::glue() |>
      ru_msg_success(verbose = verbose)
  }

  # Headers: accept CSV, set ETag if given
  extra_headers <- NULL
  if (!is.null(etag)) {
    if (odkc_version |> semver_lt("2023.3")) {
      ru_msg_warn("entitylist_download ETag is supported from v2023.3")
    }
    # If-None-Match must carry the entity-tag in its quoted form (RFC 7232).
    # This function returns the etag stripped of `W/\"` and `\"` and accepts
    # that same stripped form back, so re-add the quotes here. Sending the
    # stripped value yields a plain 200 instead of 304 Not Modified. A value
    # that is already quoted (or weak) is passed through untouched.
    if_none_match <- if (grepl('^W?".*"$', etag)) {
      etag
    } else {
      paste0('"', etag, '"')
    }
    extra_headers <- c("If-None-Match" = if_none_match)
  }

  # Query: filter
  query <- NULL
  if (!is.null(filter)) {
    query <- list("$filter" = utils::URLencode(filter, reserved = TRUE))
  }

  res <- ru_http_request(
    "GET",
    url,
    path = glue::glue(
      "v1/projects/{pid}/datasets/",
      "{utils::URLencode(did, reserved = TRUE)}/entities.csv"
    ),
    query = query,
    accept = "text/csv; charset=utf-8",
    headers = extra_headers,
    un = un,
    pw = pw,
    dest = pth,
    overwrite = overwrite,
    retries = retries
  )
  # yell_if_error(url, un, pw)  # allow HTTP 304 for no new submissions

  # 304 Not Modified carries no body and must not clobber the previous
  # download, so report entities = NULL rather than parsing an empty body.
  # The response body was streamed straight to disk, so parse the file
  # as CSV text to a tibble.
  list(
    entities = if (res$status_code == 304L) {
      NULL
    } else {
      readr::read_csv(pth)
    },
    etag = res$headers[["etag"]] |>
      stringr::str_remove_all(stringr::fixed("W/\"")) |>
      stringr::str_remove_all(stringr::fixed("\"")),
    http_status = res$status_code,
    downloaded_to = pth,
    downloaded_on = isodt_to_local(Sys.time(), orders = orders, tz = tz)
  )
}

# usethis::use_test("entitylist_download")  # nolint
