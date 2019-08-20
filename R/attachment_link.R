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

#' Change a tibble of submissions to link to local media attachments.
#'
#' A form's `form_schema` lists form fields generating attachments as type "binary".
#' The zip file downloaded by `submission_export` contains a folder "media" with
#' all attachments.
#'
#' @param data_tbl A tibble of submissions as returned by `submission_export`,
#'                 unzip and read_csv.
#' @template param-pid
#' @template param-fid
#' @param pth The local path to downloaded attachments, default: `media/`.
#'            Attachments from `submission_export` will extract to `media/`.
#'            In contrast, `attachment_get` saves to `attachments/<uuid>/` and
#'            returns that path. See vignette `restapi` for a usage example.
#' @template param-auth
#' @return The tibble of submission data with attachment filenames prefixed
#'         with local attachment folder.
#' @export
#'
#' @examples
#' \dontrun{
#' # extract from form schema names of fields with type "binary" as `att_fieldnames`
#' fs <- form_schema(Sys.getenv("ODKC_TEST_PID"), Sys.getenv("ODKC_TEST_FID"),
#'   url = Sys.getenv("ODKC_TEST_URL"), un = Sys.getenv("ODKC_TEST_UN"),
#'   pw = Sys.getenv("ODKC_TEST_PW")
#' )
#'
#' # export submissions, unzip, read_csv
#' # prepend all `attachment_fieldnames` with `att_local` path ("media")
#' # fs::file_exists verifies that local paths are correct
#' }
attachment_link <- function(data_tbl,
                            pid,
                            fid,
                            pth = "media",
                            url = Sys.getenv("ODKC_URL"),
                            un = Sys.getenv("ODKC_UN"),
                            pw = Sys.getenv("ODKC_PW")) {
  warning("Not implemented.")
  # # Names of form fields generating attachments derived from `form_schema`
  # att_cn <- form_schema(pid, fid, url = url, un = un, pw = pw) %>%
  #   form_schema_parse(.) %>%
  #   dplyr::filter(type == "binary") %>%
  #   dplyr:select("name")
  #
  # # Mutate each field name in att_cn: prepend pth
  # d <- data_tbl %>% dplyr::mutate_at(att_cn, prefix_fn(pth))
  # data_tbl
}

# Tests
# usethis::edit_file("tests/testthat/test-attachment_link.R")
