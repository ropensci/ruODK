% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/odata_entitylist_data_get.R
\name{odata_entitylist_data_get}
\alias{odata_entitylist_data_get}
\title{Get the Data Document from the OData Dataset Service.}
\usage{
odata_entitylist_data_get(
  pid = get_default_pid(),
  did = "",
  query = NULL,
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries(),
  odkc_version = get_default_odkc_version(),
  orders = get_default_orders(),
  tz = get_default_tz()
)
}
\arguments{
\item{pid}{The numeric ID of the project, e.g.: 2.

Default: \code{\link{get_default_pid}}.

Set default \code{pid} through \code{ru_setup(pid="...")}.

See \code{vignette("Setup", package = "ruODK")}.}

\item{did}{(chr) The name of the Entity List, internally called Dataset.
The function will error if this parameter is not given.
Default: "".}

\item{query}{An optional named list of query parameters, e.g.

\if{html}{\out{<div class="sourceCode">}}\preformatted{list(
  "$filter" = "__system/createdAt le 2024-11-05",
  "$orderby" = "__system/creatorId ASC, __system/conflict DESC",
  "$top" = "100",
  "$skip" = "3",
  "$count" = "true"
)
}\if{html}{\out{</div>}}

No validation is conducted by \code{ruODK} on the query list prior to
passing it to ODK Central.
If omitted, no filter query is sent.
Note that the behaviour of this parameter differs from the implementation
of \code{odata_submission_get()} in that \code{query} here accepts a list of all
possible OData query parameters and \code{odata_submission_get()} offers
individual function parameters matching supported OData query parameters.
Default: \code{NULL}}

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

\item{retries}{The number of attempts to retrieve a web resource.

This parameter is given to \code{\link[httr]{RETRY}(times = retries)}.

Default: 3.}

\item{odkc_version}{The ODK Central version as a semantic version string
(year.minor.patch), e.g. "2023.5.1". The version is shown on ODK Central's
version page \verb{/version.txt}. Discard the "v".
\code{ruODK} uses this parameter to adjust for breaking changes in ODK Central.

Default: \code{\link{get_default_odkc_version}} or "2023.5.1" if unset.

Set default \code{get_default_odkc_version} through
\code{ru_setup(odkc_version="2023.5.1")}.

See \code{vignette("Setup", package = "ruODK")}.}

\item{orders}{(vector of character) Orders of datetime elements for
lubridate.

Default:
\code{c("YmdHMS", "YmdHMSz", "Ymd HMS", "Ymd HMSz", "Ymd", "ymd")}.}

\item{tz}{A timezone to convert dates and times to.

Read \code{vignette("setup", package = "ruODK")} to learn how \code{ruODK}'s
timezone can be set globally or per function.}
}
\value{
An S3 class \code{odata_entitylist_data_get} with two list items:
\itemize{
\item \code{context} The URL for the OData metadata document
\item \code{value} A tibble of EntitySets available in this EntityList, with names
cleaned by \code{janitor::clean_names()} and unnested list columns
(\verb{__system}).
}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
}
\details{
All the Entities in a Dataset.

The \verb{$top} and \verb{$skip} querystring parameters, specified by OData, apply limit
and offset operations to the data, respectively.

The \verb{$count} parameter, also an OData standard, will annotate the response
data with the total row count, regardless of the scoping requested by \verb{$top}
and \verb{$skip}.
If \verb{$top} parameter is provided in the request then the response will include
\verb{@odata.nextLink} that you can use as is to fetch the next set of data.
As of ODK Central v2023.4, \verb{@odata.nextLink} contains a \verb{$skiptoken}
(an opaque cursor) to better paginate around deleted Entities.

The \verb{$filter} querystring parameter can be used to filter certain data fields
in the system-level schema, but not the Dataset properties.
The operators \code{lt}, \code{le}, \code{eq}, \code{ne}, \code{ge}, \code{gt}, \code{not}, \code{and}, and \code{or}
and the built-in functions \code{now}, \code{year}, \code{month}, \code{day}, \code{hour},
\code{minute}, \code{second} are supported.

The fields you can query against are as follows:

Entity Metadata:	\verb{OData Field Name}
Entity Creator Actor ID:	\verb{__system/creatorId}
Entity Timestamp:	\verb{__system/createdAt}
Entity Update Timestamp:	\verb{__system/updatedAt}
Entity Conflict:	\verb{__system/conflict}

Note that \code{createdAt} and \code{updatedAt} are time components.
This means that any comparisons you make need to account for the full time
of the entity. It might seem like \verb{$filter=__system/createdAt le 2020-01-31}
would return all results on or before 31 Jan 2020, but in fact only entities
made before midnight of that day would be accepted.
To include all of the month of January, you need to filter by either
\verb{$filter=__system/createdAt le 2020-01-31T23:59:59.999Z} or
\verb{$filter=__system/createdAt lt 2020-02-01}.
Remember also that you can query by a specific timezone.

Please see the OData documentation on \verb{$filter}
\href{http://docs.oasis-open.org/odata/odata/v4.01/cs01/part1-protocol/odata-v4.01-cs01-part1-protocol.html#sec_BuiltinFilterOperations}{operations}
and \href{http://docs.oasis-open.org/odata/odata/v4.01/cs01/part1-protocol/odata-v4.01-cs01-part1-protocol.html#sec_BuiltinQueryFunctions}{functions}
for more information.

The \verb{$select} query parameter will return just the fields you specify and is
supported on \verb{__id}, \verb{__system}, \verb{__system/creatorId}, \verb{__system/createdAt}
and \verb{__system/updatedAt}, as well as on user defined properties.

The \verb{$orderby} query parameter will return Entities sorted by different
fields, which come from the same list used by \verb{$filter}, as noted above.
The order can be specified as ASC (ascending) or DESC (descending),
which are case-insensitive. Multiple sort expressions can be used together,
separated by commas,
e.g. \verb{$orderby=__system/creatorId ASC, __system/conflict DESC}.

As the vast majority of clients only support the JSON OData format,
that is the only format ODK Central offers.
}
\examples{
\dontrun{
# See vignette("setup") for setup and authentication options
# ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")

ds <- entitylist_list(pid = get_default_pid())

ds1 <- odata_entitylist_data_get(pid = get_default_pid(), did = ds$name[1])

ds1
ds1$context
ds1$value

qry <- list(
  "$filter" = "__system/createdAt le 2024-11-05",
  "$orderby" = "__system/creatorId ASC, __system/conflict DESC",
  "$top" = "100",
  "$skip" = "3",
  "$count" = "true"
)
ds2 <- odata_entitylist_data_get(
  pid = get_default_pid(),
  did = ds$name[1],
  query = qry
)

ds2
}
}
\seealso{
\url{https://docs.getodk.org/central-api-odata-endpoints/#id3}

\url{http://docs.oasis-open.org/odata/odata/v4.01/odata-v4.01-part1-protocol.html#_Toc31358948}

Other entity-management: 
\code{\link{entity_audits}()},
\code{\link{entity_changes}()},
\code{\link{entity_create}()},
\code{\link{entity_delete}()},
\code{\link{entity_detail}()},
\code{\link{entity_list}()},
\code{\link{entity_update}()},
\code{\link{entity_versions}()},
\code{\link{entitylist_detail}()},
\code{\link{entitylist_download}()},
\code{\link{entitylist_list}()},
\code{\link{entitylist_update}()},
\code{\link{odata_entitylist_metadata_get}()},
\code{\link{odata_entitylist_service_get}()}
}
\concept{entity-management}
