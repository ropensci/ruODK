#' Download an Entity List as CSV.
#'
#' `r lifecycle::badge("maturing")`
#'
#' The downloaded file is named "entities.csv". The download location defaults
#' to the current workdir, but can be modified to a folder name.
#'
#' An Entity List is a named collection of Entities that have the same
#' properties.
#' Entity List can be linked to Forms as Attachments.
#' This will make it available to clients as an automatically-updating CSV.
#'
#' Entity Lists can be used as Attachments in other Forms, but they can also be
#' downloaded directly as a CSV file.
#' The CSV format closely matches the OData Dataset (Entity List) Service
#' format, with columns for system properties such as `__id` (the Entity UUID),
#' `__createdAt`, `__creatorName`, etc., the Entity Label label, and the
#' Dataset (Entity List )/Entity Properties themselves.
#' If any Property for an given Entity is blank (e.g. it was not captured by
#' that Form or was left blank), that field of the CSV is blank.
#'
#' The `$filter` querystring parameter can be used to filter on system-level
#' properties, similar to how filtering in the OData Dataset (Entity List)
#' Service works.
#'
#' This endpoint supports `ETag` header, which can be used to avoid downloading
#' the same content more than once. When an API consumer calls this endpoint,
#' the endpoint returns a value in the `ETag` header.
#' If you pass that value in the `If-None-Match` header of a subsequent request,
#' then if the Entity List has not been changed since the previous request,
#' you will receive 304 Not Modified response; otherwise you'll get the new
#' data.
#'
#' `r lifecycle::badge("maturing")`
#'
#' @template param-pid
#' @template param-did
#' @template param-url
#' @template param-auth
#' @param local_dir The local folder to save the downloaded files to,
#'                  default: \code{here::here}.
#' @param overwrite Whether to overwrite previously downloaded zip files,
#'                 default: FALSE
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @template param-verbose
#' @return The path to the downloaded CSV.
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
#' ds1 <- entitylist_download(pid = get_default_pid(), did = ds$name[1])
#' }
entitylist_download <- function(pid = get_default_pid(),
                              did = NULL,
                              url = get_default_url(),
                              un = get_default_un(),
                              pw = get_default_pw(),
                              local_dir = here::here(),
                              overwrite = TRUE,
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
                              tz = get_default_tz(),
                              verbose = get_ru_verbose()) {
  yell_if_missing(url, un, pw, pid = pid)

  if (is.null(did)) {
    ru_msg_abort(
      "entitylist_download requires the Entity List name as 'did=\"name\"'."
    )
  }

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entitylist_download is supported from v2022.3")
  }

  pth <- fs::path(local_dir, "entities.csv")

  if (fs::file_exists(pth)) {
    if (overwrite == TRUE) {
      "Overwriting previous entity list: \"{pth}\"" %>%
        glue::glue() %>%
        ru_msg_success(verbose = verbose)
    } else {
      "Keeping previous entity list: \"{pth}\"" %>%
        glue::glue() %>%
        ru_msg_success(verbose = verbose)

      return(pth)
    }
  } else {
    "Downloading entity list \"{did}\" to {pth}" %>%
      glue::glue() %>%
      ru_msg_success(verbose = verbose)
  }


  httr::RETRY(
    "GET",
    httr::modify_url(url,
                     path = glue::glue(
                       "v1/projects/{pid}/datasets/",
                       "{URLencode(did, reserved = TRUE)}/entities.csv"
                     )
    ),
    httr::add_headers(
      "Accept" = "text/csv"
    ),
    httr::authenticate(un, pw),
    httr::write_disk(pth, overwrite = overwrite),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8")

  pth
}


# usethis::use_test("entitylist_download")  # nolint