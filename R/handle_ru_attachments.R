#' Download and link submission attachments according to a form schema.
#'
#' `r lifecycle::badge("stable")`
#'
#' @details For a given tibble of submissions, download and link attachments
#' for all columns which are marked in the form schema as type "binary".
#' @param data Submissions rectangled into a tibble. E.g. the output of
#'   ```
#'   ruODK::odata_submission_get(parse = FALSE) %>%
#'   ruODK::odata_submission_rectangle()
#'   ```
#' @param form_schema The `form_schema` for the submissions.
#'   E.g. the output of `ruODK::form_schema()`.
#' @param local_dir The local folder to save the downloaded files to,
#'   default: "media".
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-verbose
#' @return The submissions tibble with all attachments downloaded and linked to
#'   a `local_dir`.
#' @export
#' @family utilities
#' @examples
#' \dontrun{
#' library(magrittr)
#' data("fq_raw")
#' data("fq_form_schema")
#' t <- tempdir()
#' fs::dir_ls(t) %>% fs::file_delete()
#' fq_with_att <- fq_raw %>%
#'   ruODK::odata_submission_rectangle() %>%
#'   ruODK::handle_ru_attachments(
#'     form_schema = fq_form_schema,
#'     local_dir = t,
#'     pid = ruODK::get_test_pid(),
#'     fid = ruODK::get_test_fid(),
#'     url = ruODK::get_test_url(),
#'     un = ruODK::get_test_un(),
#'     pw = ruODK::get_test_pw(),
#'     verbose <- ruODK::get_ru_verbose()
#'   )
#' # There should be files in local_dir
#' testthat::expect_true(fs::dir_ls(t) %>% length() > 0)
#' }
#'
handle_ru_attachments <- function(data,
                                  form_schema,
                                  local_dir = "media",
                                  pid = get_default_pid(),
                                  fid = get_default_fid(),
                                  url = get_default_url(),
                                  un = get_default_un(),
                                  pw = get_default_pw(),
                                  retries = get_retries(),
                                  verbose = get_ru_verbose()) {
  # Find attachment columns
  # Caveat: if an attachment field has no submissions, it is dropped from data
  # This works for the main table "Submissions"
  att_cols_main <- form_schema %>%
    dplyr::filter(type == "binary") %>%
    magrittr::extract2("ruodk_name") %>%
    intersect(names(data))

  if (length(att_cols_main) > 0) {
    x <- paste(att_cols_main, collapse = ", ") # nolint
    "Found attachments in main Submissions table: {x}." %>%
      glue::glue() %>%
      ru_msg_info(verbose = verbose)
    ru_msg_info("Downloading attachments...", verbose = verbose)
    data <- data %>%
      dplyr::mutate_at(
        dplyr::vars(dplyr::all_of(att_cols_main)),
        ~ ruODK::attachment_get(
          id,
          .,
          local_dir = local_dir,
          verbose = verbose,
          pid = pid,
          fid = fid,
          url = url,
          un = un,
          pw = pw,
          retries = retries
        )
      )
  }

  # This fetches the attachment cols of any nested subtable "Submissions.GROUP"
  att_cols_sub <- form_schema %>%
    dplyr::filter(type == "binary") %>%
    magrittr::extract2("name") %>%
    intersect(names(data))

  if (length(att_cols_sub) > 0) {
    x <- paste(att_cols_sub, collapse = ", ") # nolint
    "Found attachments in nested sub-table: {x}." %>%
      glue::glue() %>%
      ru_msg_info(verbose = verbose)
    ru_msg_info("Downloading attachments...", verbose = verbose)
    data <- data %>%
      dplyr::mutate_at(
        dplyr::vars(dplyr::all_of(att_cols_sub)),
        ~ ruODK::attachment_get(
          submissions_id,
          .,
          local_dir = local_dir,
          verbose = verbose,
          pid = pid,
          fid = fid,
          url = url,
          un = un,
          pw = pw,
          retries = retries
        )
      )
  }

  data
}

# usethis::use_test("handle_ru_attachments") # nolint
