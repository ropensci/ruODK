#' ## Structure
#' The response from ODK Central from this endpoint is irregular and dynamic.
#' Depending on the life history of records in ODK Central, some parts may be
#' populated with deeply nested structures, empty, or missing.
#' `ruODK` preserves the original structure as not to introduce additional
#' complexity. If a use case exists to decompose the original structure further
#' please create a GitHub issue.
#'
