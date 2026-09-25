#' Enable Project Managed Encryption.
#'
#' `r lifecycle::badge("experimental")`
#'
#' Project Managed Encryption can be enabled via the API.
#' To do this, POST with the passphrase and optionally a reminder hint about
#' the passphrase.
#' If managed encryption is already enabled, a 409 error response will be
#' returned.
#' Enabling managed encryption will modify all unencrypted Forms in the
#' Project, and as a result the version of all Forms within the Project will
#' also be modified.
#' It is therefore best to enable managed encryption before devices are in
#' the field.
#' Any Forms in the Project that already have self-supplied encryption keys
#' will be left alone.
#' This endpoint requires ODK Central v0.6 or later.
#'
#' @template param-pid
#' @param passphrase (character) The encryption passphrase.
#'   If this passphrase is lost, the data will be irrecoverable.
#' @param hint (character) A reminder about the passphrase.
#'   This is primarily useful when multiple encryption keys and passphrases
#'   are being used, to tell them apart.
#'   Default: `NULL` (no hint).
#' @template param-url
#' @template param-auth
#' @template param-retries
#' @template param-odkcv
#' @return A list with a single element `success` (`TRUE`) as per the ODK
#'   Central API docs.
# nolint start
#' @seealso \url{https://docs.getodk.org/central-api-project-management/#enabling-project-managed-encryption}
# nolint end
#' @family project-management
#' @export
#' @examples
#' \dontrun{
#' # See vignette("setup") for setup and authentication options
#' # ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")
#'
#' p <- project_create(name = "Encrypted Project")
#'
#' project_enable_encryption(
#'   pid = p$id,
#'   passphrase = "super duper secret",
#'   hint = "it was a secret"
#' )
#' # > $success
#' # > [1] TRUE
#' }
project_enable_encryption <- function(
  pid = get_default_pid(),
  passphrase,
  hint = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version()
) {
  yell_if_missing(url, un, pw, pid = pid)

  if (odkc_version |> semver_lt("0.6")) {
    ru_msg_warn("project_enable_encryption is supported from v0.6")
  }

  if (
    missing(passphrase) ||
      !is.character(passphrase) ||
      length(passphrase) != 1L ||
      is.na(passphrase) ||
      !nzchar(passphrase)
  ) {
    ru_msg_abort("passphrase must be a single non-empty character string.")
  }

  body <- list(passphrase = passphrase)
  if (!is.null(hint)) {
    body$hint <- hint
  }

  ru_http_request(
    "POST",
    url,
    path = glue::glue("v1/projects/{pid}/key"),
    un = un,
    pw = pw,
    body = body,
    encode = "json",
    retries = retries
  ) |>
    yell_if_error(url, un, pw) |>
    httr::content(encoding = "utf-8") |>
    janitor::clean_names()
}

# usethis::use_test("project_enable_encryption")  # nolint
