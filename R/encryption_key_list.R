#' List all encryption keys for a form.
#'
#' `r lifecycle::badge("maturing")`
#'
#' This endpoint provides a listing of all known encryption keys needed to
#' decrypt all Submissions for a given Form. It will return at least the
#' `base64RsaPublicKey` property (as column `public`) of all known versions
#' of the form that have submissions against them.
#' If managed keys are being used and a hint was provided, that will be returned
#' as well.
#'
#' @template param-pid
#' @template param-fid
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-orders
#' @template param-tz
#' @return A tibble of encryption keys.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/submissions/listing-encryption-keys}
# nolint end
#' @family submission-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' x <- encryption_key_list(
#'   pid = Sys.getenv("ODKC_TEST_PID_ENC"),
#'   fid = Sys.getenv("ODKC_TEST_FID_ENC"),
#'   url = get_test_url(),
#'   un = get_test_un(),
#'   pw = get_test_pw()
#'  )
#'
#' names(x)
#' #> [1] "id" "public" "managed" "hint" "created_at"
#' }
encryption_key_list <- function(pid = get_default_pid(),
                                fid = get_default_fid(),
                                url = get_default_url(),
                                un = get_default_un(),
                                pw = get_default_pw(),
                                retries = get_retries(),
                                orders = c(
                                  "YmdHMS",
                                  "YmdHMSz",
                                  "Ymd HMS",
                                  "Ymd HMSz",
                                  "Ymd",
                                  "ymd"
                                ),
                                tz = get_default_tz()){
  yell_if_missing(url, un, pw)
  httr::RETRY(
    "GET",
    httr::modify_url(
      url,
      path = glue::glue(
        "v1/projects/{pid}/forms/",
        "{URLencode(fid, reserved = TRUE)}/submissions/keys"
      )
    ),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    tibble::tibble(.) %>%
    tidyr::unnest_wider(".", names_repair = "universal") %>%
    janitor::clean_names(.) %>%
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")), # assume datetimes are named "_at"
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("encryption_key_list")
