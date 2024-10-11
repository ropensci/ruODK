#' List all submissions of one form.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-orders
#' @template param-tz
#' @return A tibble containing some high-level details of the form submissions.
#'         One row per submission, columns are submission attributes:
#'
#'         * instance_id: uuid, string. The unique ID for each submission.
#'         * submitter_id: user ID, integer.
#'         * created_at: time of submission upload, dttm
#'         * updated_at: time of submission update on server, dttm or NA
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-submission-management/#listing-all-submissions-on-a-form}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette("setup")
#' ruODK::ru_setup(
#'   svc = ...,
#'   un = "me@email.com",
#'   pw = "..."
#' )
#'
#' sl <- submission_list()
#' sl %>% knitr::kable(.)
#'
#' fl <- form_list()
#'
#' # submission_list returns a tibble
#' class(sl)
#' # > c("tbl_df", "tbl", "data.frame")
#'
#' # Submission attributes are the tibble's columns
#' names(sl)
#' # > "instance_id" "submitter_id" "device_id" "created_at" "updated_at"
#'
#' # Number of submissions (rows) is same as advertised in form_list
#' form_list_nsub <- fl %>%
#'   filter(fid == get_test_fid()) %>%
#'   magrittr::extract2("submissions") %>%
#'   as.numeric()
#' nrow(sl) == form_list_nsub
#' # > TRUE
#' }
submission_list <- function(pid = get_default_pid(),
                            fid = get_default_fid(),
                            url = get_default_url(),
                            un = get_default_un(),
                            pw = get_default_pw(),
                            retries = get_retries(),
                            orders = get_default_orders(),
                            tz = get_default_tz()) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  url <- httr::modify_url(
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}/submissions"
    )
  )
  httr::RETRY(
    "GET",
    url,
    httr::add_headers(
      "Accept" = "application/json",
      "X-Extended-Metadata" = "true"
    ),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    tibble::tibble(.) %>%
    tidyr::unnest_wider(".", names_repair = "universal") %>%
    tidyr::unnest_wider(
      "submitter",
      names_repair = "universal", names_sep = "_"
    ) %>%
    janitor::clean_names() %>%
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")), # assume datetimes are named "_at"
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("submission_list") # nolint
