#' List all users
#'
#' `r lifecycle::badge("maturing")`
#'
#' Currently, there are no paging or filtering options, so listing Users will
#' get you every User in the system, every time.
#' Optionally, a q querystring parameter may be provided to filter the returned
#' users by any given string.
#' The search is performed via a trigram similarity index over both the Email
#' and Display Name fields, and results are ordered by match score, best matches
#' first.
#' If a q parameter is given, and it exactly matches an email address that
#' exists in the system, that user's details will always be returned,
#' even for actors who cannot user.list.
#' The request must still authenticate as a valid Actor.
#' This allows non-Administrators to choose a user for an action
#' (eg. grant rights) without allowing full search.
#'
#'
#' Actors who cannot `user.list` will always receive [] with a 200 OK response.
#' ruODK does not (yet) warn if this is the case, and you (the requesting Actor)
#' have no permission to `user.list`.
#'
#' @param qry A query string to filter users by. The query string is not case
#'   sensitive and can contain special characters, such as `@`.
#'   The query string must be at least 5 alphabetic characters long to
#'   return good enough matches.
#'   E.g. `janet` will match a user with display name `Janette Doe`.
#'   E.g., `@dbca.wa` will match users with an email from `dbca.wa.gov.au`,
#'   whereas `@dbca.w` or `@dbca` will return no matches.
#'   Default: `NULL`.
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @template param-verbose
#' @return TODO
# nolint start
#' @seealso \url{https://odkcentral.docs.apiary.io/#reference/accounts-and-users/users/listing-all-users}
# nolint end
#' @seealso \url{https://www.postgresql.org/docs/9.6/pgtrgm.html}
#' @family user-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette "setup" for authentication options
#' ruODK::ru_setup(
#'   svc = "....svc",
#'   un = "me@email.com",
#'   pw = "..."
#' )
#'
#' # All users
#' ul <- user_list()
#'
#' # Search users
#' # Given a user with display name "Janette Doe" and email "@org.com.au"
#' user_list(qry="jan")     # no results, query string too short
#' user_list(qry="jane")    # no results, query string too short
#' user_list(qry="janet")   # returns Janette
#' user_list(qry="@org")    # no results, query string too short
#' user_list(qry="@org.c")  # no results, query string too short
#' user_list(qry="@org.co") # returns all users matching "@org.co"
#'
#' # Actor not allowed to user.list
#' user_list() # If this is empty, you might not have permissions to list users
#' }
user_list <- function(qry = NULL,
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
                      tz = get_default_tz(),
                      verbose = get_ru_verbose()) {
  yell_if_missing(url, un, pw)

  if(!is.null(qry)) {
    "Returning users with display name or email matching \"{qry}\"" %>%
    glue::glue() %>% ru_msg_info(verbose = verbose)

    if(nchar(qry)<5) glue::glue(
      "Short query strings might not return any matches, ",
      "provide a query string containing at least 5 alphanumeric characters."
    ) %>% ru_msg_warn(verbose = verbose)
  }

  # TODO warn if requesting user (un) has no permissions to user.list
  # and will receive an empty list without warning from ODK Central.
  # This requires support for roles and assignments.

  httr::RETRY(
    "GET",
    httr::modify_url(url, path = glue::glue("v1/users"), query = list(q=qry)),
    httr::authenticate(un, pw),
    times = retries
  ) %>%
    yell_if_error(., url, un, pw) %>%
    httr::content(.) %>%
    tibble::tibble(.) %>%
    tidyr::unnest_wider(".", names_repair = "universal") %>%
    janitor::clean_names() %>%
    dplyr::mutate_at(
      dplyr::vars(dplyr::contains("_at")), # assume datetimes are named "_at"
      ~ isodt_to_local(., orders = orders, tz = tz)
    )
}

# usethis::use_test("user_list") # nolint