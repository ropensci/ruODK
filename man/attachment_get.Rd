% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/attachment_get.R
\name{attachment_get}
\alias{attachment_get}
\title{Download attachments and return the local path}
\usage{
attachment_get(pid, fid, submission_uuid, attachment_filename,
  local_dir = "attachments", url = Sys.getenv("ODKC_URL"),
  un = Sys.getenv("ODKC_UN"), pw = Sys.getenv("ODKC_PW"),
  verbose = FALSE)
}
\arguments{
\item{pid}{The numeric ID of the project, e.g.: 2.}

\item{fid}{The alphanumeric form ID, e.g. "build_Spotlighting-0-8_1559885147".}

\item{submission_uuid}{One or many ODK submission UUIDs, an MD5 hash}

\item{attachment_filename}{One or many ODK form attachment filenames,
e.g. "1558330537199.jpg"}

\item{local_dir}{The local folder to save the downloaded files to,
default: "attachments"}

\item{url}{The OData URL, ending in .svc, no trailing slash.}

\item{un}{The ODK Central username (an email address),
default: Sys.getenv("ODKC_UN").
Add to your ~/.Rprofile: Sys.setenv(ODKC_UN="...@...")}

\item{pw}{The ODK Central password,,
default: Sys.getenv("ODKC_PW").
Add to your ~/.Rprofile: Sys.setenv(ODKC_PW="...")}

\item{verbose}{Whether to display debug messages or not (default)}
}
\value{
The relative file path for the downloaded attachment(s)
}
\description{
This function is vectorised and can handle either one or many records.
Parameters submission_uuid and attachment_filename accept single or exactly
the same number of multiple values.
The other parameters are automatically repeated.
}
\details{
The media attachments are downloaded into a folder named by the submission's
uuid inside the given `local_dir`. E.g.:

workdir/attachments/xxxxxxxxxx/filename1.jpg

workdir/attachments/xxxxxxxxxx/filename2.jpg

workdir/attachments/xxxxxxxxxx/filename3.jpg

https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/'-form-attachments/downloading-a-form-attachment

https://odkcentral.docs.apiary.io/#reference/forms-and-submissions/attachments/downloading-an-attachment
}