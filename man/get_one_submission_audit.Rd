% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/submission_audit_get.R
\name{get_one_submission_audit}
\alias{get_one_submission_audit}
\title{Download server audit logs for one submission.}
\usage{
get_one_submission_audit(
  iid,
  pid = get_default_pid(),
  fid = get_default_fid(),
  url = get_default_url(),
  un = get_default_un(),
  pw = get_default_pw(),
  retries = get_retries()
)
}
\arguments{
\item{iid}{The \code{instance_id}, a UUID, as returned by
\code{\link{submission_list}}.}

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

\item{retries}{The number of attempts to retrieve a web resource.

This parameter is given to \code{\link[httr]{RETRY}(times = retries)}.

Default: 3.}
}
\value{
A nested list of submission data.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
}
\details{
This function is the workhorse for the vectorised function
submission_audit_get,
which gets all server audit logs for a list of submission IDs.

Note this function returns a nested list containing any repeating subgroups.
As the presence and length of repeating subgroups is non-deterministic and
entirely depends on the completeness of the submission data, we cannot
rectangle them any further here. Rectangling requires knowledge of the form
schema and the completeness of submission data.

\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}
}
\examples{
\dontrun{
# See vignette("setup") for setup and authentication options
# ruODK::ru_setup(svc = "....svc", un = "me@email.com", pw = "...")

# With explicit credentials, see tests
sl <- submission_list()

sub <- get_one_submission_audit(sl$instance_id[[1]])
listviewer::jsonedit(sub)

# The details for one submission depend on the form fields
length(sub)
# > 11

# The items are the field names. Repeated groups have the same name.
names(sub)
# > "meta"                     "encounter_start_datetime" "reporter"
# > "device_id"                "location"                 "habitat"
# > "vegetation_structure"     "perimeter"                "taxon_encounter"
# > "taxon_encounter"          "encounter_end_datetime"
}
}
\seealso{
\url{https://docs.getodk.org/central-api-submission-management/#retrieving-audit-logs}

Other utilities: 
\code{\link{attachment_get}()},
\code{\link{attachment_link}()},
\code{\link{attachment_url}()},
\code{\link{drop_null_coords}()},
\code{\link{form_schema_parse}()},
\code{\link{get_one_attachment}()},
\code{\link{get_one_submission}()},
\code{\link{get_one_submission_attachment_list}()},
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
\code{\link{split_geotrace}()},
\code{\link{strip_uuid}()},
\code{\link{tidyeval}},
\code{\link{unnest_all}()}
}
\concept{utilities}
