#' Delete an Entity List.
#'
#' `r lifecycle::badge("experimental")`
#'
#' When a Dataset is deleted, it is soft-deleted and placed in the trash.
#' After 30 days in the trash, the Dataset and all of its Entities are
#' automatically purged.
#' Unlike Forms, deleted Datasets cannot be restored.
#' A Dataset cannot be deleted while any Forms still use it, either as a
#' source of Entities or as a consumer through an attachment.
#' Update or delete those Forms first.
#' This endpoint requires ODK Central 2026.1 or later.
#'
#' @template tpl-def-entitylist
#' @template tpl-entitylist-dataset
#' @template tpl-auth-missing
#' @template param-pid
#' @template param-did
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @template param-orders
#' @template param-tz
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-dataset-management/#deleting-a-dataset}
# nolint end
#' @family entity-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' entitylist_delete(did = "trees")
#' # > $success
#' # > [1] TRUE
#' }
entitylist_delete <- function(
  pid = get_default_pid(),
  did = "",
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz()
) {
  yell_if_missing(url, un, pw, pid = pid, did = did)

  if (odkc_version |> semver_lt("2026.1")) {
    ru_msg_warn("entitylist_delete is supported from v2026.1")
  }

  ru_http_request(
    "DELETE",
    url,
    path = glue::glue(
      "v1/projects/{pid}/datasets/",
      "{URLencode(did, reserved = TRUE)}"
    ),
    un = un,
    pw = pw,
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("entitylist_delete")  # nolint
