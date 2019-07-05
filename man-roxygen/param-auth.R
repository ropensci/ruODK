#' @param url The OData URL, ending in .svc, no trailing slash.
#' @param un The ODK Central username (an email address),
#'           default: Sys.getenv("ODKC_UN").
#'           Add to your ~/.Rprofile: Sys.setenv(ODKC_UN="...@...")
#' @param pw The ODK Central password,,
#'           default: Sys.getenv("ODKC_PW").
#'           Add to your ~/.Rprofile: Sys.setenv(ODKC_PW="...")
