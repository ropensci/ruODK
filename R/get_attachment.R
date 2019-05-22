#' Download attachments and return the local path
#'
#' @param base_url The ODK Central OData base url,
#'                 e.g. "https://sandbox.central.opendatakit.org/v1/projects/14/forms/"
#' @param form_id The ODK form ID, e.g. "build_Flora-Quadrat-0-1_1558330379"
#' @param submission_uuid The ODK submission UUID, an MD5 hash
#' @param attachment_filename The ODK form attachment filename,
#'                            e.g. "1558330537199.jpg"
#' @param local_dir The local folder to save the downloaded files to,
#'                  default: "attachments"
#' @param un The ODK Central username (an email address),
#'           default: Sys.getenv("ODKC_UN").
#'           Add to your ~/.Rprofile: Sys.setenv(ODKC_UN="...@...")
#' @param pw The ODK Central password,,
#'           default: Sys.getenv("ODKC_PW").
#'           Add to your ~/.Rprofile: Sys.setenv(ODKC_PW="...")
#' @return The relative file path for the downloaded attachment
#' @export
#' @importFrom glue glue
#' @importFrom httr authenticate GET write_disk
get_attachment <- function(
  base_url,
  form_id,
  submission_uuid,
  attachment_filename,
  local_dir="attachments",
  un=Sys.getenv("ODKC_UN"),
  pw=Sys.getenv("ODKC_PW")
){

  # Create local destination dir attachments/uuid
  dest_dir <- glue::glue("{local_dir}/{submission_uuid}")
  dir.create(dest_dir, recursive = T)

  source_url <- glue::glue("{base_url}{form_id}/",
                           "submissions/{submission_uuid}/",
                           "attachments/{attachment_filename}")

  dest_path <- glue::glue("{dest_dir}/{attachment_filename}")

  # Keep existing
  if (!file.exists(dest_path) && !is.na(attachment_filename)){
    httr::GET(
      source_url,
      httr::authenticate(un, pw),
      httr::write_disk(dest_path, overwrite=T)
    )
  }

  # Return the relative path to the attechment
  return(dest_path %>% as.character)
}