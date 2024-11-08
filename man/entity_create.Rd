% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/entity_create.R
\name{entity_create}
\alias{entity_create}
\title{Creates exactly one Entity in the Dataset.}
\usage{
entity_create(
  pid = get_default_pid(),
  did = "",
  label = "",
  uuid = "",
  notes = "",
  data = list(),
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

\item{label}{(character) The Entity label which must be a non-empty string.
If the label is given, a single entity is created using \code{data}, \code{notes},
and \code{uuid} if given.
If the label is kept at the default (or omitted), multiple entities are
created using \code{data} and \code{notes} and ignoring \code{uuid}.
Default: \code{""}.}

\item{uuid}{(character) A single UUID to assign to the entity.
Default: \code{""}. With the default, Central will create and assign a UUID.
This parameter is only used when creating a single entity (\code{label}
non-empty) and ignored when creating multiple entities (\code{label} empty).}

\item{notes}{(character) Metadata about the request which can be retrieved
using the entity audit log.
Default: \code{""}.}

\item{data}{(list) A named list of Entity properties to create a single
Entity, or a nested list with an array of Entity data to create multiple
Entities. The nested lists representing individual entities must be valid
as in they must contain a label, valid data for the respective entity
properties, and can contain an optional UUID.
See details and the ODK documentation for the exact format.
Default: \code{list()}.}

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
A nested list identical to the return value of \code{entity_detail}.
See \url{https://docs.getodk.org/central-api-entity-management/#creating-entities}
for the full schema.
Top level list elements are renamed from ODK's \code{camelCase} to \code{snake_case}.
Nested list elements have the original \code{camelCase}.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
}
\details{
\subsection{Creating a single Entity}{

For creating a single Entity, include
\itemize{
\item An optional \code{uuid}. If skipped, Central will create a UUID for the Entity.
\item The Entity \code{label} must be non-empty.
\item A named list \code{data} representing the Entity's fields. The value type of
all properties is string.
}

\code{uuid = "..."}
\code{label = "John Doe"}
\code{data = list("firstName" = "John", "age" = "22")}

This translates to JSON

\verb{\{ "label": "John Doe", "data": \{ "firstName": "John", "age": "22" \} \}}
}

\subsection{Creating multiple Entities}{

For creating multiple Entities in bulk, the request body takes an array
entities containing a list of Entity objects as described above.
The bulk entity version also takes a source property with a required name
field and optional size, for example to capture the file name and size of a
bulk upload source (in MB).

\if{html}{\out{<div class="sourceCode">}}\preformatted{data=list(
    "entities" = c(
      list("label" = "Entity 1", "data" = list("field1" = "value1")),
      list("label" = "Entity 2", "data" = list("field1" = "value2"))
    ),
    "source" = list("name" = "file.csv", "size" = 100)
  )
}\if{html}{\out{</div>}}

This translates to JSON

\verb{\{ "entities": [...], "source": \{"name": "file.csv", "size": 100\} \}}

You can provide \code{notes} to store the metadata about the request.
The metadata is included in the POST request as header \code{X-Action-Notes} and
can retrieved using Entity Audit Log.
}
}
\examples{
\dontrun{
# See vignette("setup") for setup and authentication options
# ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")

el <- entitylist_list()

# Entity List name (dataset ID, did)
did <- el$name[1]

# All Entities of Entity List
en <- entity_list(did = did)

# Create a single entity
ec <- entity_create(
  did = did,
  label = "Entity label",
  notes = "Metadata about the created entity",
  data = list("field1" = "value1", "field2" = "value1")
)
ec

# Create multiple entities, example: test form "problems"
label <- c(
  glue::glue(
    "Entity {nrow(en) + 1} created by ruODK package test on {Sys.time()}"
  ),
  glue::glue(
    "Entity {nrow(en) + 2} created by ruODK package test on {Sys.time()}"
  )
)
notes <- glue::glue("Two entities created by ruODK package test on {Sys.time()}")
status <- c("needs_followup", "needs_followup")
details <- c("ruODK package test", "ruODK package test")
geometry <- c("-33.2 115.0 0.0 0.0", "-33.2 115.0 0.0 0.0")
data <- data.frame(status, details, geometry, stringsAsFactors = FALSE)
request_data <- list(
  "entities" = data.frame(label, data = I(data), stringsAsFactors = FALSE),
  "source" = list("name" = "file.csv", "size" = 100)
)

# Compare request_data to the schema expected by Central
# https://docs.getodk.org/central-api-entity-management/#creating-entities
# jsonlite::toJSON(request_data, pretty = TRUE, auto_unbox = TRUE)

ec <- entity_create(
  did = did,
  notes = notes,
  data = request_data
)
}
}
\seealso{
\url{https://docs.getodk.org/central-api-entity-management/#creating-entities}

Other entity-management: 
\code{\link{entity_audits}()},
\code{\link{entity_changes}()},
\code{\link{entity_delete}()},
\code{\link{entity_detail}()},
\code{\link{entity_list}()},
\code{\link{entity_update}()},
\code{\link{entity_versions}()},
\code{\link{entitylist_detail}()},
\code{\link{entitylist_download}()},
\code{\link{entitylist_list}()},
\code{\link{entitylist_update}()},
\code{\link{odata_entitylist_data_get}()},
\code{\link{odata_entitylist_metadata_get}()},
\code{\link{odata_entitylist_service_get}()}
}
\concept{entity-management}
