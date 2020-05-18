#' @param form_schema An optional form_schema,
#'   like the output of \code{\link{form_schema}}. If a form schema is supplied,
#'   location fields will not be unnested. While WKT location fields contain
#'   plain text and will never be unnested, GeoJSON location fields would cause
#'   errors during unnesting.
