#' Download attachments and return the local path
#'
#' This function is vectorised and can handle either one or many records.
#' Parameters submission_uuid and attachment_filename accept single or exactly
#' the same number of multiple values.
#' The other parameters are automatically repeated.
#'
#' @param base_url The ODK Central OData base url,
#'                 e.g. "https://sandbox.central.opendatakit.org/v1/projects/14/forms/"
#' @param form_id The ODK form ID, e.g. "build_Flora-Quadrat-0-1_1558330379"
#' @param submission_uuid One or many ODK submission UUIDs, an MD5 hash
#' @param attachment_filename One or many ODK form attachment filenames,
#'                            e.g. "1558330537199.jpg"
#' @param local_dir The local folder to save the downloaded files to,
#'                  default: "attachments"
#' @param un The ODK Central username (an email address),
#'           default: Sys.getenv("ODKC_UN").
#'           Add to your ~/.Rprofile: Sys.setenv(ODKC_UN="...@...")
#' @param pw The ODK Central password,,
#'           default: Sys.getenv("ODKC_PW").
#'           Add to your ~/.Rprofile: Sys.setenv(ODKC_PW="...")
#' @param verbose Whether to display debug messages or not (default)
#' @return The relative file path for the downloaded attachment(s)
#' @importFrom glue glue
#' @importFrom fs dir_create dir_exists path_expand
#' @importFrom httr authenticate GET write_disk
#' @importFrom purrr pmap
#' @export
get_attachment <- function(
                           base_url,
                           form_id,
                           submission_uuid,
                           attachment_filename,
                           local_dir = "attachments",
                           un = Sys.getenv("ODKC_UN"),
                           pw = Sys.getenv("ODKC_PW"),
                           verbose = FALSE) {
  # Create local destination dir attachments/uuid
  dest_dir <- fs::path(local_dir, submission_uuid)
  if (verbose == TRUE) message(glue::glue("Using local directory: {dest_dir}\n\n"))
  fs::dir_create(dest_dir)

  dest_file <- fs::path(dest_dir, attachment_filename)

  source_url <- glue::glue(
    "{base_url}{form_id}/submissions/{submission_uuid}/",
    "attachments/{attachment_filename}"
  )

  get_one_attachment <- function(pth, fn, src, un, pw) {
    if (!fs::file_exists(pth) && !is.na(fn)) {
      httr::GET(
        src,
        httr::authenticate(un, pw),
        httr::write_disk(pth, overwrite = T)
      )
    }
    if (verbose == TRUE) message(glue::glue("Saved {pth}\n\n"))
    return(pth %>% as.character())
  }

  a <- tibble::tibble(
    pth = dest_file,
    fn = attachment_filename,
    src = source_url,
    un = un,
    pw = pw
  )

  purrr::pmap(a, get_one_attachment)
}
