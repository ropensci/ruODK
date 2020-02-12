#' Prefix attachment columns from CSV export with a local attachment file path.
#'
#' \lifecycle{maturing}
#'
#' @param data_tbl The downloaded submissions from
#'   \code{\link{submission_export}} read into a `tibble` by
#'   \code{readr::read_csv}.
#' @param att_path A local path, default: "media" (as per .csv.zip export).
#'   Selected columns of the dataframe (containing attchment filenames) are
#'   prefixed with `att_path`, thus turning them into relative paths.
#' @param att_contains A shared part of attachment fieldnames, default: "photo".
#'   Columns of the dataframe are selected by the presence of `att_contains`.
#' @return The dataframe with attachment columns modified to contain relative
#'   paths to the downloaded attachment files.
#' @export
#' @family restful-api
#' @examples
#' \dontrun{
#' t <- tempdir()
#' # Set default credentials, see vignette "setup"
#' ruODK::ru_setup(
#'   svc = paste0(
#'     "https://sandbox.central.opendatakit.org/v1/projects/14/",
#'     "forms/build_Flora-Quadrat-0-2_1558575936.svc"
#'   ),
#'   un = "me@email.com",
#'   pw = "..."
#' )
#'
#' # Predict filenames (with knowledge of form)
#' fid <- get_default_fid()
#' fid_csv <- fs::path(t, glue::glue("{fid}.csv"))
#' fid_csv_tae <- fs::path(t, glue::glue("{fid}-taxon_encounter.csv"))
#'
#' # Download the zip file
#' se <- ruODK::submission_export(
#'   local_dir = t,
#'   overwrite = FALSE,
#'   verbose = TRUE
#' )
#'
#' # Unpack the zip file
#' f <- unzip(se, exdir = t)
#' fs::dir_ls(t)
#'
#' # Prepend attachments with media/ to turn into relative file paths
#' data_quadrat <- fid_csv %>%
#'   readr::read_csv(na = c("", "NA", "na")) %>%
#'   janitor::clean_names(.) %>%
#'   attachment_link(.) %>%
#'   ru_datetime(tz = "Australia/Perth")
#' }
attachment_link <- function(data_tbl,
                            att_path = "media",
                            att_contains = "photo") {
  data_tbl %>%
    dplyr::mutate_at(
      dplyr::vars(tidyr::contains(att_contains)),
      ~ fs::path(att_path, .)
    )

  # TODO auto-detect field names of type "binary" (attachments) from form_schema
  # att_cn <- form_schema(pid, fid, url = url, un = un, pw = pw) %>%
  #   form_schema_parse(.) %>%
  #   dplyr::filter(type == "binary") %>%
  #   dplyr:select("name")
}

# Tests
# usethis::edit_file("tests/testthat/test-attachment_link.R")
# usethis::edit_file("tests/testthat/test-submission_export.R")
