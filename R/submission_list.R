#' List all submissions of one form.
#'
#' `r lifecycle::badge("stable")`
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble containing some high-level details of the form submissions.
#'         One row per submission, columns are submission attributes:
#'
#'         * instance_id: uuid, string. The unique ID for each submission.
#'         * submitter_id: user ID, integer.
#'         * created_at: time of submission upload, dttm
#'         * updated_at: time of submission update on server, dttm or NA
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/listing-all-submissions-on-a-form}
# nolint end
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
#' # Set default credentials, see vignette("setup")
#' ruODK::ru_setup(
#'   svc = paste0(
#'     "https://sandbox.central.getodk.org/v1/projects/14/",
#'     "forms/build_Flora-Quadrat-0-2_1558575936.svc"
#'   ),
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
                            retries = get_retries()) {
  yell_if_missing(url, un, pw, pid = pid, fid = fid)
  url <- httr::modify_url(
    url,
    path = glue::glue(
      "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}/submissions"
    )
  )
  ru_msg_info(url)
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
    { # nolint
      tibble::tibble(
        instance_id = purrr::map_chr(., "instanceId"),
        submitter_id = purrr::map_int(., c("submitter", "id"), .default = NA),
        device_id = purrr::map_chr(., "deviceId", .default = NA),
        created_at = purrr::map_chr(., "createdAt", .default = NA) %>%
          isodt_to_local(),
        updated_at = purrr::map_chr(., "updated_at", .default = NA) %>%
          isodt_to_local(),
      )
    }
}

# usethis::use_test("submission_list") # nolint
