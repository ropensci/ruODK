% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/handle_ru_geopoints.R
\name{handle_ru_geopoints}
\alias{handle_ru_geopoints}
\title{Split all geopoints of a submission tibble into their components.}
\usage{
handle_ru_geopoints(data, form_schema, wkt = FALSE, verbose = get_ru_verbose())
}
\arguments{
\item{data}{Submissions rectangled into a tibble. E.g. the output of

\if{html}{\out{<div class="sourceCode">}}\preformatted{ruODK::odata_submission_get(parse = FALSE) \%>\%
ruODK::odata_submission_rectangle()
}\if{html}{\out{</div>}}}

\item{form_schema}{The \code{form_schema} for the submissions.
E.g. the output of \code{ruODK::form_schema()}.}

\item{wkt}{Whether geofields are GeoJSON (if FALSE) or WKT
strings (if TRUE), default: FALSE.}

\item{verbose}{Whether to display debug messages or not.

Read \code{vignette("setup", package = "ruODK")} to learn how \code{ruODK}'s
verbosity can be set globally or per function.}
}
\value{
The submissions tibble with all geopoints retained in their original
format, plus columns of their coordinate components as provided by
\code{\link{split_geopoint}}.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}
}
\details{
For a given tibble of submissions, find all columns which are listed
in the form schema as type \code{geopoint}, and extract their components.
Extracted components are longitude (X), latitude (Y), altitude (Z, where
given), and accuracy (M, where given).

The original column is retained to allow parsing into other spatially
enabled formats.
}
\examples{
library(magrittr)
data("geo_fs")
data("geo_gj_raw")
data("geo_wkt_raw")

# GeoJSON
geo_gj_parsed <- geo_gj_raw \%>\%
  ruODK::odata_submission_rectangle(form_schema = geo_fs) \%>\%
  ruODK::handle_ru_geopoints(form_schema = geo_fs, wkt = FALSE)

dplyr::glimpse(geo_gj_parsed)

# WKT
geo_wkt_parsed <- geo_wkt_raw \%>\%
  ruODK::odata_submission_rectangle(form_schema = geo_fs) \%>\%
  ruODK::handle_ru_geopoints(form_schema = geo_fs, wkt = TRUE)

dplyr::glimpse(geo_wkt_parsed)
}
\seealso{
Other utilities: 
\code{\link{attachment_get}()},
\code{\link{attachment_link}()},
\code{\link{attachment_url}()},
\code{\link{drop_null_coords}()},
\code{\link{form_schema_parse}()},
\code{\link{get_one_attachment}()},
\code{\link{get_one_submission}()},
\code{\link{get_one_submission_attachment_list}()},
\code{\link{get_one_submission_audit}()},
\code{\link{handle_ru_attachments}()},
\code{\link{handle_ru_datetimes}()},
\code{\link{handle_ru_geoshapes}()},
\code{\link{handle_ru_geotraces}()},
\code{\link{isodt_to_local}()},
\code{\link{odata_submission_rectangle}()},
\code{\link{predict_ruodk_name}()},
\code{\link{prepend_uuid}()},
\code{\link{split_geopoint}()},
\code{\link{split_geoshape}()},
\code{\link{split_geotrace}()},
\code{\link{strip_uuid}()},
\code{\link{tidyeval}},
\code{\link{unnest_all}()}
}
\concept{utilities}
