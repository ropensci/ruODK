#' Update Entity List details.
#'
#' `r lifecycle::badge("maturing")`
#'
#' You can only update `approvalRequired` using this endpoint.
#' The  `approvalRequired` flag controls the Entity creation flow;
#' if it is true then the Submission must be approved before an Entity can be
#' created from it and if it is false then an Entity is created as soon as the
#' Submission is received by the ODK Central.
#' By default `approvalRequired` is false for the Entity Lists created after
#' v2023.3. Entity Lists created prior to that will have `approvalRequired` set
#' to true.
#'
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template tpl-compat-2022-3
#' @template param-pid
#' @template param-did
#' @param approval_required (lgl) The value to set `approvalRequired` to.
#'   If TRUE, a Submission must be approved before an Entity is created,
#'   if FALSE, an Entity is created as soon as the Submission is received by
#'   ODK Central.
#'   Default: `FALSE`.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A list of lists following the exact format and naming of the API
#'   response for `entitylist_detail`.
#'   Since this nested list is so deeply nested and irregularly shaped
#'   it is not trivial to rectangle the result into a tibble.
# nolint start
#' @seealso \url{ https://docs.getodk.org/central-api-dataset-management/#datasets}
# nolint end
#' @family dataset-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' pid <- get_default_pid()
#'
#' ds <- entitylist_list(pid = pid)
#'
#' did <- ds$name[1]
#'
#' ds1 <- entitylist_detail(pid = pid, did = did)
#' ds1$approvalRequired # FALSE
#'
#' ds2 <- entitylist_update(pid = pid, did = did, approval_required = TRUE)
#' ds2$approvalRequired # TRUE
#'
#' ds3 <- entitylist_update(pid = pid, did = did, approval_required = FALSE)
#' ds3$approvalRequired # FALSE
#' }
entitylist_update <- function(pid = get_default_pid(),
                              did = "",
                              approval_required = FALSE,
                              url = get_default_url(),
                              un = get_default_un(),
                              pw = get_default_pw(),
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
                              tz = get_default_tz()) {
  yell_if_missing(url, un, pw, pid = pid, did = did)

  if (odkc_version |> semver_lt("2022.3")) {
    ru_msg_warn("entitylist_update is supported from v2022.3")
  }

  ds <- httr::RETRY(
    "PATCH",
    httr::modify_url(url,
      path = glue::glue(
        "v1/projects/{pid}/datasets/",
        "{URLencode(did, reserved = TRUE)}"
      )
    ),
    httr::add_headers(
      "Accept" = "application/json"
    ),
    encode = "json",
    body = list(approvalRequired = approval_required),
    httr::authenticate(un, pw),
    times = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("entitylist_update") # nolint
