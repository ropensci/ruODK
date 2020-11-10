#' Get server audit log entries.
#'
#' `r lifecycle::badge("stable")`
#'
#' Parameters to filter the audit logs:
#' `action=form.create&start=2000-01-01z&end=2000-12-31T23%3A59.999z`
#'
#' @param action string. The action to filter the logs, e.g. "user.create".
# nolint start
#'   See \url{https://odkcentral.docs.apiary.io/#reference/system-endpoints/server-audit-logs/}
# nolint end
#'   for the full list of available actions.
#' @param start string. The ISO8601 timestamp of the earliest log entry to
#'   return.
#'   E.g. `2000-01-01z` or `2000-12-31T23:59.999z`, `2000-01-01T12:12:12+08` or
#'   `2000-01-01+08`.
#' @param end string. The ISO8601 timestamp of the last log entry to return.
#' @param limit integer. The max number of log entries to return.
#' @param offset integer. The number of log entries to skip.
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @return A tibble containing server audit logs.
#'  One row per audited action, columns are submission attributes:
#'
#'  * actor_id: integer. The ID of the actor, if any, that initiated the
#'    action.
#'  * action: string. The action that was taken.
#'  * actee_id: uuid, string. The ID of the permissioning object against
#'    which the action was taken.
#'  * details: list. Additional details about the action that vary
#'    according to the type of action.
#'  * logged_at: dttm. Time of action on server.
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/system-endpoints/server-audit-logs/getting-audit-log-entries}
# nolint end
#' @family restful-api
#' @export
#' @examples
#' \dontrun{
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
#' logs <- audit_get()
#'
#' # With search parameters
#' logs <- audit_get(
#'   action = "project.update",
#'   start = "2019-08-01Z",
#'   end = "2019-08-31Z",
#'   limit = 100,
#'   offset = 0
#' )
#'
#' # With partial search parameters
#' logs <- audit_get(
#'   limit = 100,
#'   offset = 0
#' )
#'
#' logs %>% knitr::kable(.)
#'
#' # audit_get returns a tibble
#' class(logs)
#' # > c("tbl_df", "tbl", "data.frame")
#'
#' # Audit details
#' names(logs)
#' # > "actor_id" "action" "actee_id" "details" "logged_at"
#' }
audit_get <- function(action = NULL,
                      start = NULL,
                      end = NULL,
                      limit = NULL,
                      offset = NULL,
                      url = Sys.getenv("ODKC_URL"),
                      un = Sys.getenv("ODKC_UN"),
                      pw = Sys.getenv("ODKC_PW"),
                      retries = get_retries()) {
  yell_if_missing(url, un, pw)
  qry <- list(
    action = action,
    start = start,
    end = end,
    limit = limit,
    offset = offset
  ) %>%
    Filter(Negate(is.null), .)
  httr::RETRY(
    "GET",
    httr::modify_url(url, path = glue::glue("v1/audits")),
    httr::add_headers("Accept" = "application/json"),
    httr::authenticate(un, pw),
    query = qry,
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    { # nolint
      tibble::tibble(
        actor_id = purrr::map_int(., "actorId", .default = NA),
        action = purrr::map_chr(., "action"),
        actee_id = purrr::map_chr(., "acteeId", .default = NA),
        details = purrr::map(., "details"),
        logged_at = purrr::map_chr(., "loggedAt", .default = NA) %>%
          isodt_to_local(),
      )
    }
}

# usethis::edit_file("tests/testthat/test-audit_get.R") # nolint
