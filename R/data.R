#' OData service document for an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The OData response for the metadata of an ODK Central form.
#'
#' This data is kept up to date with the data used in vignettes and package
#' tests. The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' @format A tibble with one row per submission data endpoint.
#' @source OData service document for
#'   `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' @family included
"fq_svc"


#' OData metadata document for an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The OData response for the metadata of an ODK Central form.
#'
#' This data is kept up to date with the data used in vignettes and package
#' tests. The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' @format A list of lists
#' @source See `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' @family included
"fq_meta"


#' JSON form schema for an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The parsed form schema of an ODK Central form.
#'
#' This data is kept up to date with the data used in vignettes and package
#' tests. The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' This data is used to build vignettes offline and without the need for
#' credentials to an ODK Central server. The test suite ensures that the
#' "canned" data is identical to the "live" data.
#'
#' @format The output of `ruODK::form_schema()`, a tibble with columns "type",
#'   "name" and "path" and one row per form field.
#'
#' @source See `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#'   and `ruODK::form_schema()`.
#' @family included
"fq_form_schema"


#' OData submission data for an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The OData response for the submissions of an ODK Central form.
#' This form represents a Flora Quadrat, which is a ca 50 by 50 m quadrat of
#' a uniform plant community.
#'
#' The XML and .odkbuild versions for this form are available as
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' and `system.file("extdata", "FloraQuadrat04.odkbuild", package = "ruODK")`,
#' respectively.
#'
#' This data is kept up to date with the data used in vignettes and package
#' tests. The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' @format A list of lists
#' @source See `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' @family included
"fq_raw"


#' OData submission data for a subgroup of an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The OData response for the subgroup of an ODK Central form.
#'
#' This subgroup represents vegetation strata as per the NVIS classification.
#' A vegetation stratum is a layer of plants with the same height, and dominated
#' by one or few plant taxa. Plant communities can be made of up to five strata,
#' with two to three being most common.
#'
#' This data is kept up to date with the data used in vignettes and package
#' tests. The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' @format A list of lists
#' @source See `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' @family included
"fq_raw_strata"


#' OData submission data for a subgroup of an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The OData response for a subgroup of an ODK Central form.
#'
#' This subgroup represents an individual plant taxon which is encountered by
#' the enumerators. Typically, one voucher specimen is taken for each distinct
#' encountered plant taxon. A field name is allocated by the enumerators, which
#' can be the proper canonical name (if known) or any other moniker.
#' The voucher specimens are later determined by taxonomic experts, who then
#' provide the real, terminal taxonomic name for a given voucher specimen.
#'
#' This data is kept up to date with the data used in vignettes and package
#' tests. The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' @format A list of lists
#' @source See `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' @family included
"fq_raw_taxa"


#' Parsed submission data for an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The parsed OData response for the submissions of an ODK Central form.
#' This form represents a Flora Quadrat, which is a ca 50 by 50 m quadrat of
#' a uniform plant community.
#'
#' The XML and .odkbuild versions for this form are available as
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' and `system.file("extdata", "FloraQuadrat04.odkbuild", package = "ruODK")`,
#' respectively.
#'
#' This data is kept up to date with the data used in vignettes and package
#' tests. The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' @format The output of \code{\link{odata_submission_get}} for a set of example
#'   data. A tidy tibble referencing the attachments included in the vignettes
#'   and documentation at a relative path `attachments/media/<filename>.<ext>`.
#' @source See `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#'   and \code{\link{odata_submission_get}}.
#' @family included
"fq_data"


#' Parsed submission data for a subgroup of an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The parsed OData response for the subgroup of an ODK Central form.
#'
#' This subgroup represents vegetation strata as per the NVIS classification.
#' A vegetation stratum is a layer of plants with the same height, and dominated
#' by one or few plant taxa. Plant communities can be made of up to five strata,
#' with two to three being most common.
#'
#' This data is kept up to date with the data used in vignettes and package
#' tests. The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' @format The output of \code{\link{odata_submission_get}} for a set of example
#'   data. A tidy tibble referencing the attachments included in the vignettes
#'   and documentation at a relative path `attachments/media/<filename>.<ext>`.
#' @source See `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#'   and \code{\link{odata_submission_get}}.
#' @family included
"fq_data_strata"


#' Parsed submission data for a subgroup of an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The parsed OData response for a subgroup of an ODK Central form.
#'
#' This subgroup represents an individual plant taxon which is encountered by
#' the enumerators. Typically, one voucher specimen is taken for each distinct
#' encountered plant taxon. A field name is allocated by the enumerators, which
#' can be the proper canonical name (if known) or any other moniker.
#' The voucher specimens are later determined by taxonomic experts, who then
#' provide the real, terminal taxonomic name for a given voucher specimen.
#'
#' This data is kept up to date with the data used in vignettes and package
#' tests. The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' @format The output of \code{\link{odata_submission_get}} for a set of example
#'   data. A tidy tibble referencing the attachments included in the vignettes
#'   and documentation at a relative path `attachments/media/<filename>.<ext>`.
#' @source See `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#'   and \code{\link{odata_submission_get}}.
#' @family included
"fq_data_taxa"


#' A tibble of submission attachments.
#'
#' \lifecycle{stable}
#'
#' @format A tibble of submission attachments.
#' @source The output of \code{\link{attachment_list}}
#' run on submissions of the test form
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"fq_attachments"


#' A tibble of form metadata.
#'
#' \lifecycle{stable}
#'
#' @format A tibble of form metadata.
#' @source The output of \code{\link{form_detail}}
#' run on submissions of the test form
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"fq_form_detail"


#' A tibble of forms.
#'
#' \lifecycle{stable}
#'
#' @format A tibble of forms
#' @source The output of \code{\link{form_list}}.
#' run on the project.
#' @family included
#' @encoding UTF-8
"fq_form_list"


#' A tibble of form fields and field types.
#'
#' \lifecycle{stable}
#'
#' @format A tibble of form fields and field types.
#' @source The output of \code{\link{form_schema}}
#' run on the test form
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"fq_form_schema"


#' A nested list of a form definition.
#'
#' \lifecycle{stable}
#'
#' @format A nested list of a form definition.
#' @source The output of \code{\link{form_xml}}
#' run on the test form
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"fq_form_xml"


#' A tibble of project metadata.
#'
#' \lifecycle{stable}
#'
#' @format A tibble of project metadata.
#' @source The output of \code{\link{project_detail}}
#' run on the project containing the test form
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`.
#' @family included
"fq_project_detail"


#' A tibble of project metadata.
#'
#' \lifecycle{stable}
#'
#' @format A tibble of project metadata.
#' @source The output of \code{\link{project_list}}
#' run on all projects on the configured ODK Central server.
#' @family included
#' @encoding UTF-8
"fq_project_list"


#' A tibble of submission metadata.
#'
#' \lifecycle{stable}
#'
#' @format A tibble of submission metadata.
#' @source The output of \code{\link{submission_list}}
#' run on the test form
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"fq_submission_list"


#' A nested list of submission data.
#'
#' \lifecycle{stable}
#'
#' @format A nested list of submission data.
#' @source The output of \code{\link{submission_get}}
#' run on the test form
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' using submission instance IDs from \code{\link{submission_list}}.
#' @family included
#' @encoding UTF-8
"fq_submissions"

#' A tibble of the main data table of records from a test form.
#'
#' \lifecycle{stable}
#'
#' @format A tibble of main records from a test form.
#' @source \code{\link{submission_export}}
#' run on the test form
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"fq_zip_data"


#' A tibble of a repeated sub-group of records from a test form.
#'
#' \lifecycle{stable}
#'
#' @format A tibble of repeated sub-group of records from a test form.
#' @source \code{\link{submission_export}}
#' run on the test form
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"fq_zip_strata"


#' A tibble of a repeated sub-group of records from a test form.
#'
#' \lifecycle{stable}
#'
#' @format A tibble of repeated sub-group of records from a test form.
#' @source \code{\link{submission_export}}
#' run on the test form
#' `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"fq_zip_taxa"

#' The form_schema of a form containing geofields in GeoJSON.
#'
#' \lifecycle{stable}
#'
#' @source \code{\link{form_schema}}
#' run on the test form
#' `system.file("extdata", "Locations.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"geo_fs"

#' The unparsed submissions of a form containing geofields in GeoJSON.
#'
#' \lifecycle{stable}
#'
#' @source \code{\link{odata_submission_get}(wkt=FALSE, parse=FALSE)}
#' run on the test form
#' `system.file("extdata", "Locations.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"geo_gj_raw"

#' The parsed submissions of a form containing geofields in GeoJSON.
#'
#' \lifecycle{stable}
#'
#' @source \code{\link{odata_submission_get}(wkt=FALSE, parse=TRUE)}
#' run on the test form
#' `system.file("extdata", "Locations.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"geo_gj"

#' The unparsed submissions of a form containing geofields in WKT.
#'
#' \lifecycle{stable}
#'
#' @source \code{\link{odata_submission_get}(wkt=TRUE, parse=FALSE)}
#' run on the test form
#' `system.file("extdata", "Locations.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"geo_wkt_raw"

#' The parsed submissions of a form containing geofields in WKT.
#'
#' \lifecycle{stable}
#'
#' @source \code{\link{odata_submission_get}(wkt=TRUE, parse=TRUE)}
#' run on the test form
#' `system.file("extdata", "Locations.xml", package = "ruODK")`.
#' @family included
#' @encoding UTF-8
"geo_wkt"