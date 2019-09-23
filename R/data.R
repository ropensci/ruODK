#' OData service document for an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The OData response for the metadata of an ODK Central form.
#'
#' This data is kept up to date with the data used in vignettes and package tests.
#' The data is comprised of test records with nonsensical data.
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
#' This data is kept up to date with the data used in vignettes and package tests.
#' The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' @format A list of lists
#' @source See `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' @family included
"fq_meta"

#' OData submission data for an ODK Central form.
#'
#' \lifecycle{stable}
#'
#' The OData response for the submissions of an ODK Central form.
#' This form represents a Flora Quadrat, which is a ca 50 by 50 m quadrat of
#' a uniform plant community.
#'
#' The XML and .odkbuild versions for this form are
#' available as `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' and `system.file("extdata", "FloraQuadrat04.odkbuild", package = "ruODK")`,
#' respectively.
#'
#' This data is kept up to date with the data used in vignettes and package tests.
#' The data is comprised of test records with nonsensical data.
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
#' This data is kept up to date with the data used in vignettes and package tests.
#' The data is comprised of test records with nonsensical data.
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
#' This data is kept up to date with the data used in vignettes and package tests.
#' The data is comprised of test records with nonsensical data.
#' The forms used to capture this data are development versions of real-world
#' forms.
#'
#' @format A list of lists
#' @source See `system.file("extdata", "FloraQuadrat04.xml", package = "ruODK")`
#' @family included
"fq_raw_taxa"
