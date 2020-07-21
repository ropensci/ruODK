#' Prefix attachment columns from CSV export with a local attachment file path.
#'
#' \lifecycle{stable}
#'
#' @param data_tbl The downloaded submissions from
#'   \code{\link{submission_export}} read into a `tibble` by
#'   \code{readr::read_csv}.
#' @param form_schema The `form_schema` for the submissions.
#'   E.g. the output of `ruODK::form_schema()`.
#' @param att_path A local path, default: "media" (as per .csv.zip export).
#'   Selected columns of the dataframe (containing attchment filenames) are
#'   prefixed with `att_path`, thus turning them into relative paths.
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
#'     "https://sandbox.central.getodk.org/v1/projects/14/",
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
#' fs <- form_schema()
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
#'   janitor::clean_names() %>%
#'   handle_ru_datetimes(fs) %>%
#'   attachment_link(fs)
#' }
attachment_link <- function(data_tbl,
                            form_schema,
                            att_path = "media") {
  # Find attachment columns
  # Caveat: if an attachment field has no submissions, it is dropped from data
  att_cols <- form_schema %>%
    dplyr::filter(type == "binary") %>%
    magrittr::extract2("ruodk_name") %>%
    intersect(names(data_tbl))

  data_tbl %>%
    dplyr::mutate_at(
      dplyr::vars(tidyselect::all_of(att_cols)),
      ~ fs::path(att_path, .)
    )
}

# nolint start
# usethis::edit_file("tests/testthat/test-attachment_link.R")
# usethis::edit_file("tests/testthat/test-submission_export.R")
# nolint end
