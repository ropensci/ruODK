% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/odata_submission_get.R
\name{odata_submission_get}
\alias{odata_submission_get}
\title{Retrieve and rectangle form submissions, parse dates, geopoints, download and
link attachments.}
\usage{
odata_submission_get(
  table = "Submissions",
  skip = NULL,
  top = NULL,
  count = FALSE,
  wkt = FALSE,
  expand = FALSE,
  filter = NULL,
  parse = TRUE,
  download = TRUE,
  orders = c("YmdHMS", "YmdHMSz", "Ymd HMS", "Ymd HMSz", "Ymd", "ymd"),
  local_dir = "media",
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  odkc_version = get_default_odkc_version(),
  tz = get_default_tz(),
  retries = get_retries(),
  verbose = get_ru_verbose()
)
}
\arguments{
\item{table}{The submission EntityType, or in plain words, the table name.
Default: \code{Submissions} (the main table).
Change to \code{Submissions.GROUP_NAME} for repeating form groups.
The group name can be found through \code{\link{odata_service_get}}.}

\item{skip}{The number of rows to be omitted from the results.
Example: 10, default: \code{NA} (none skipped).}

\item{top}{The number of rows to return.
Example: 100, default: \code{NA} (all returned).}

\item{count}{If TRUE, an \code{@odata.count} property will be returned in the
response from ODK Central. Default: \code{FALSE}.}

\item{wkt}{If TRUE, geospatial data will be returned as WKT (Well Known Text)
strings. Default: \code{FALSE}, returns GeoJSON structures.
Note that accuracy is only returned through GeoJSON.}

\item{expand}{If TRUE, all subtables will be expanded and included with
column names containing the number of the repeat, the group name, and the
field name. This parameter is supported from ODK Central v1.2 onwards and
will be ignored on earlier versions of ODK Central. The version is inferred
from the parameter \code{odkc_version}.
Default: FALSE.}

\item{filter}{If provided, will filter responses to those matching the query.
For an \code{odkc_version} below 1.1, this parameter will be discarded.
As of ODK Central v1.5, the fields \code{system/submitterId},
\code{system/submissionDate}, \verb{__system/updatedAt}  and \verb{__system/reviewState}
are available to reference.
The operators \code{lt}, \code{lte}, \code{eq}, \code{neq}, \code{gte}, \code{gt}, \code{not}, \code{and}, and \code{or}
are supported, and the built-in functions
\code{now}, \code{year}, \code{month}, \code{day}, \code{hour}, \code{minute}, \code{second.}
\code{ruODK} does not validate the query string given to \code{filter}.
It is highly recommended to refer to the ODK Central API documentation
as well as the
\href{https://docs.oasis-open.org/odata/odata/v4.01/odata-v4.01-part1-protocol.html#_Toc31358948}{OData spec on filters}.
for filter options and capabilities.}

\item{parse}{Whether to parse submission data based on form schema.
Dates and datetimes will be parsed into local time.
Attachments will be downloaded, and the field updated to the local file
path.
Point locations will be split into components; GeoJSON (\code{wkt=FALSE})
will be split into latitude, longitude, altitude and accuracy
(with anonymous field names), while WKT will be split into
longitude, latitude,and altitude (missing accuracy) prefixed by
the original field name.
See details for the handling of geotraces and geoshapes.
Default: TRUE.}

\item{download}{Whether to download attachments to \code{local_dir} or not.
If in the future ODK Central supports hot-linking attachments,
this parameter will replace attachment file names with their fully
qualified attachment URL.
Default: TRUE.}

\item{orders}{(vector of character) Orders of datetime elements for
lubridate.
Default:
\code{c("YmdHMS", "YmdHMSz", "Ymd HMS", "Ymd HMSz", "Ymd", "ymd")}.}

\item{local_dir}{The local folder to save the downloaded files to,
default: \code{"media"}.}

\item{pid}{The numeric ID of the project, e.g.: 2.

Default: \code{\link{get_default_pid}}.

Set default \code{pid} through \code{ru_setup(pid="...")}.

See \code{vignette("Setup", package = "ruODK")}.}

\item{fid}{The alphanumeric form ID, e.g. "build_Spotlighting-0-8_1559885147".

Default: \code{\link{get_default_fid}}.

Set default \code{fid} through \code{ru_setup(fid="...")}.

See \code{vignette("Setup", package = "ruODK")}.}

\item{url}{The ODK Central base URL without trailing slash.

Default: \code{\link{get_default_url}}.

Set default \code{url} through \code{ru_setup(url="...")}.

See \code{vignette("Setup", package = "ruODK")}.}

\item{un}{The ODK Central username (an email address).
Default: \code{\link{get_default_un}}.
Set default \code{un} through \code{ru_setup(un="...")}.
See \code{vignette("Setup", package = "ruODK")}.}

\item{pw}{The ODK Central password.
Default: \code{\link{get_default_pw}}.
Set default \code{pw} through \code{ru_setup(pw="...")}.
See \code{vignette("Setup", package = "ruODK")}.}

\item{odkc_version}{The ODK Central version as a semantic version string
(year.minor.patch), e.g. "2023.5.1". The version is shown on ODK Central's
version page \verb{/version.txt}. Discard the "v".
\code{ruODK} uses this parameter to adjust for breaking changes in ODK Central.

Default: \code{\link{get_default_odkc_version}} or "2023.5.1" if unset.

Set default \code{get_default_odkc_version} through
\code{ru_setup(odkc_version="2023.5.1")}.

See \code{vignette("Setup", package = "ruODK")}.}

\item{tz}{A timezone to convert dates and times to.

Read \code{vignette("setup", package = "ruODK")} to learn how \code{ruODK}'s
timezone can be set globally or per function.}

\item{retries}{The number of attempts to retrieve a web resource.

This parameter is given to \code{\link[httr]{RETRY}(times = retries)}.

Default: 3.}

\item{verbose}{Whether to display debug messages or not.

Read \code{vignette("setup", package = "ruODK")} to learn how \code{ruODK}'s
verbosity can be set globally or per function.}
}
\value{
A list of lists.
\itemize{
\item \code{value} contains the submissions as list of lists.
\item \code{@odata.context} is the URL of the metadata.
\item \code{@odata.count} is the total number of rows in the table.
}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}
}
\details{
\code{\link{odata_submission_get}} downloads submissions from
(default) the main form group (submission table) including any non-repeating
form groups, or from any other table as specified by parameter \code{table}.

With parameter \code{parse=TRUE} (default), submission data is parsed into a
tibble. Any fields of type \code{dateTime} or \code{date} are parsed into
dates, with an optional parameter \code{tz} to specify the local timezone.

A parameter \code{local_dir} (default: \code{media}) specifies a local
directory for downloaded attachment files.
Already existing, previously downloaded attachments will be retained.

With parameter \code{wkt=TRUE}, spatial fields will be returned as WKT, rather
than GeoJSON. In addition, fields of type \code{geopoint} will be split into
latitude, longitude, and altitude, prefixed with the original field name.
E.g. a field \code{start_location} of type \code{geopoint} will be split into
\code{start_location_latitude}, \code{start_location_longitude}, and
\code{start_location_altitude}. The field name prefix will allow multiple fields
of type \code{geopoint} to be split into their components without naming
conflicts.

Geotraces (lines) and gepshapes (polygons) will be retained in their original
format, plus columns of their first point's coordinate components as
provided by \code{\link{split_geotrace}} and \code{\link{split_geoshape}},
respectively.

Entirely unpopulated form fields, as well as notes and form groups, will be
excluded from the resulting tibble.
Submitting at least one complete form instance will prevent the accidental
exclusion of an otherwise mostly empty form field.

The only remaining manual step is to optionally join any sub-tables to the
master table.

The parameter \code{verbose} enables diagnostic messages along the download
and parsing process.

With parameter \code{parse=FALSE}, submission data is presented as nested
list, which is the R equivalent of the JSON structure returned from the API.
From there, \code{\link{odata_submission_rectangle}} can rectangle the data
into a tibble, and subsequent lines of \code{\link{handle_ru_datetimes}},
\code{\link{handle_ru_attachments}}, \code{\link{handle_ru_geopoints}},
\code{\link{handle_ru_geotraces}}, and \code{\link{handle_ru_geoshapes}}
parse dates, download and link file attachments, and extract coordinates from
geofields.
\code{ruODK} offers this manual and explicit pathway as an option to
investigate and narrow down unexpected or unwanted behaviour.
}
\examples{
\dontrun{
# See vignette("setup") for setup and authentication options
# ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")

form_tables <- ruODK::odata_service_get()
data <- odata_submission_get() # default: main data table
data <- odata_submission_get(table = form_tables$url[1]) # same, explicitly
data_sub1 <- odata_submission_get(table = form_tables$url[2]) # sub-table 1
data_sub2 <- odata_submission_get(table = form_tables$url[3]) # sub-table 2

# Skip one row, return the next 1 rows (top), include total row count
data <- odata_submission_get(
  table = form_tables$url[1],
  skip = 1,
  top = 1,
  count = TRUE
)

# Filter submissions
data <- odata_submission_get(
  table = form_tables$url[1],
  filter = "year(__system/submissionDate) lt year(now())"
)
data <- odata_submission_get(
  table = form_tables$url[1],
  filter = "year(__system/submissionDate) lt 2020"
)

# To include all of the month of January, you need to filter by either
# filter = "__system/submissionDate le 2020-01-31T23:59:59.999Z"
# or
# filter = "__system/submissionDate lt 2020-02-01".
# Instead of timezone UTC ("Z"), you can also filter by any other timezone.
}
}
\seealso{
\url{https://docs.getodk.org/central-api-odata-endpoints/#odata-form-service}

\url{https://docs.getodk.org/central-api-odata-endpoints/#data-document}

Other odata-api: 
\code{\link{odata_metadata_get}()},
\code{\link{odata_service_get}()}
}
\concept{odata-api}
