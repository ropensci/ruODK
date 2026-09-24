#' Prepare a Form definition for upload.
#'
#' Internal helper that turns an XML string or a local `.xml`, `.xls`
#' or `.xlsx` file into the body, content type and extra headers of a
#' Form upload request.
#' Not part of the public API.
#'
#' @param xml An XForms XML definition as a single string, or `NULL`.
#' @param file A path to a local form definition file, or `NULL`.
#' @param xls_form_id_fallback A form ID for spreadsheets that do not
#'   specify one, or `NULL`.
#' @return A list with `body`, `content_type` and `extra_headers`.
#' @keywords internal
#' @name ru_form_upload
NULL

#' @rdname ru_form_upload
ru_form_upload <- function(
  xml = NULL,
  file = NULL,
  xls_form_id_fallback = NULL
) {
  content_type <- "application/xml"
  extra_headers <- list()
  body <- NULL

  if (!is.null(file)) {
    if (
      !is.character(file) ||
        length(file) != 1L ||
        is.na(file)
    ) {
      ru_msg_abort("file must be a single file path.")
    }
    if (!file.exists(file)) {
      ru_msg_abort(glue::glue("File not found: {file}"))
    }
    ext <- tolower(tools::file_ext(file))
    if (ext == "xml") {
      body <- paste(readLines(file, warn = FALSE), collapse = "\n")
    } else if (ext %in% c("xls", "xlsx")) {
      content_type <- if (ext == "xlsx") {
        paste0(
          "application/vnd.openxmlformats-officedocument.",
          "spreadsheetml.sheet"
        )
      } else {
        "application/vnd.ms-excel"
      }
      body <- readBin(file, "raw", file.info(file)$size)
      if (!is.null(xls_form_id_fallback)) {
        extra_headers[["X-XlsForm-FormId-Fallback"]] <-
          xls_form_id_fallback
      }
    } else {
      ru_msg_abort("file must end in '.xml', '.xls' or '.xlsx'.")
    }
  } else {
    body <- xml
  }

  list(
    body = body,
    content_type = content_type,
    extra_headers = extra_headers
  )
}

# usethis::use_test("ru_form_upload")  # nolint
