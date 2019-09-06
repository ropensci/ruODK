#' Parse a form schema into a tibble of name, type, and path.
#'
#' @param fs A form schema as returned by `form_schema`
#' @return A tibble with a row for each form field and three columns:
#'   * name The field name
#'   * type The field type
#'   * path The field path as list of named nodes
form_schema_parse <- function(fs) {
  # TODO: magic goes here
  rlang::warn("Not implemented.")
  fs
}

#' Prefix a filename and return an fs::path
#'
#' @param fn A filename (string)
#' @param prefix a prefix (string)
#' @return A fs::path "prefix/fn"
prefix_fn <- function(fn, prefix) {
  fs::path(prefix, fn)
}

#' Prefix attachment columns from CSV export with a local attachment file path.
#'
#' @param data_tbl The downloaded submissions from
#'   \code{`ruODK::submission_export()`} read into a `tibble` by
#'   \code{`readr::read_csv()`}.
#' @param att_path A local path, defaule: "media" (as per .csv.zip export).
#'   Selected columns of the dataframe (containing attchment filenames) are
#'   prefixed with `att_path`, thus turning them into relative paths.
#' @param att_contains A shared part of attachment fieldnames, default: "photo".
#'   Columns of the dataframe are selected by the presence of `att_contains`.
#' @return The dataframe with attachment columns modified to contain relative
#'   paths to the downloaded attachment files.
#' @export
#' @examples
#' \dontrun{
#' t <- tempdir()
#' # Predict filenames (with knowledge of form)
#' fid <- Sys.getenv("ODKC_TEST_FID")
#' fid_csv <- fs::path(t, glue::glue("{fid}.csv"))
#' fid_csv_tae <- fs::path(t, glue::glue("{fid}-taxon_encounter.csv"))
#'
#' # Download the zip file
#' se <- ruODK::submission_export(
#'   Sys.getenv("ODKC_TEST_PID"),
#'   Sys.getenv("ODKC_TEST_FID"),
#'   local_dir = t,
#'   overwrite = FALSE,
#'   verbose = TRUE,
#'   url = Sys.getenv("ODKC_TEST_URL"),
#'   un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
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
#'   parse_datetime(tz = "Australia/Perth")
#'
#'
#' # Cleanup
#' fs::dir_delete(t)
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
