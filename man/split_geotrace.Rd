% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/split_geotrace.R
\name{split_geotrace}
\alias{split_geotrace}
\title{Annotate a dataframe containing a geotrace column with lon, lat, alt of the
geotrace's first point.}
\usage{
split_geotrace(
  data,
  colname,
  wkt = FALSE,
  odkc_version = get_default_odkc_version()
)
}
\arguments{
\item{data}{(dataframe) A dataframe with a geotrace column.}

\item{colname}{(chr) The name of the geotrace column.
This column will be retained.}

\item{wkt}{Whether geofields are GeoJSON (if FALSE) or WKT
strings (if TRUE), default: FALSE.}

\item{odkc_version}{The ODK Central version as a semantic version string
(year.minor.patch), e.g. "2023.5.1". The version is shown on ODK Central's
version page \verb{/version.txt}. Discard the "v".
\code{ruODK} uses this parameter to adjust for breaking changes in ODK Central.

Default: \code{\link{get_default_odkc_version}} or "2023.5.1" if unset.

Set default \code{get_default_odkc_version} through
\code{ru_setup(odkc_version="2023.5.1")}.

See \code{vignette("Setup", package = "ruODK")}.}
}
\value{
The given dataframe with the geotrace column colname, plus
three new columns, \code{colname_longitude}, \code{colname_latitude},
\code{colname_altitude}.
The three new columns are prefixed with the original \code{colname} to
avoid naming conflicts with any other geotrace columns.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}
}
\details{
This function is used by \code{\link{handle_ru_geopoints}}
on all \code{geopoint} fields as per \code{\link{form_schema}}.

The format of the geotrace (GeoJSON, WKT, ODK Linestring) is determined via
parameters \code{wkt} and \code{odkc_version}, rather than inferred from the class of
the column. ODK Linestrings are character vectors without a leading
"LINESTRING (", WKT are character vectors with a leading "LINESTRING (",
and GeoJSON are list columns.
}
\examples{
\dontrun{
library(magrittr)
data("geo_fs")
data("geo_wkt_raw")
data("geo_gj_raw")

# Find variable names of geotraces
geo_fields <- geo_fs \%>\%
  dplyr::filter(type == "geotrace") \%>\%
  magrittr::extract2("ruodk_name")
geo_fields[1] # First geotrace in data: path_location_path_gps

# Rectangle but don't parse submission data (GeoJSON and WKT)
geo_gj_rt <- geo_gj_raw \%>\%
  odata_submission_rectangle(form_schema = geo_fs)
geo_wkt_rt <- geo_wkt_raw \%>\%
  odata_submission_rectangle(form_schema = geo_fs)

# Data with first geotrace split
gj_first_gt <- split_geotrace(geo_gj_rt, geo_fields[1], wkt = FALSE)
testthat::expect_true(
  "path_location_path_gps_longitude" \%in\% names(gj_first_gt)
)
testthat::expect_true(
  "path_location_path_gps_latitude" \%in\% names(gj_first_gt)
)
testthat::expect_true(
  "path_location_path_gps_altitude" \%in\% names(gj_first_gt)
)
testthat::expect_true(
  is.numeric(gj_first_gt$path_location_path_gps_longitude)
)
testthat::expect_true(
  is.numeric(gj_first_gt$path_location_path_gps_latitude)
)
testthat::expect_true(
  is.numeric(gj_first_gt$path_location_path_gps_altitude)
)

wkt_first_gt <- split_geotrace(geo_wkt_rt, geo_fields[1], wkt = TRUE)
testthat::expect_true(
  "path_location_path_gps_longitude" \%in\% names(wkt_first_gt)
)
testthat::expect_true(
  "path_location_path_gps_latitude" \%in\% names(wkt_first_gt)
)
testthat::expect_true(
  "path_location_path_gps_altitude" \%in\% names(wkt_first_gt)
)
testthat::expect_true(
  is.numeric(wkt_first_gt$path_location_path_gps_longitude)
)
testthat::expect_true(
  is.numeric(wkt_first_gt$path_location_path_gps_latitude)
)
testthat::expect_true(
  is.numeric(wkt_first_gt$path_location_path_gps_altitude)
)
}
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
\code{\link{handle_ru_geopoints}()},
\code{\link{handle_ru_geoshapes}()},
\code{\link{handle_ru_geotraces}()},
\code{\link{isodt_to_local}()},
\code{\link{odata_submission_rectangle}()},
\code{\link{predict_ruodk_name}()},
\code{\link{prepend_uuid}()},
\code{\link{split_geopoint}()},
\code{\link{split_geoshape}()},
\code{\link{strip_uuid}()},
\code{\link{tidyeval}},
\code{\link{unnest_all}()}
}
\concept{utilities}
