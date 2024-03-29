% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ru_setup.R
\name{yell_if_missing}
\alias{yell_if_missing}
\title{Abort on missing ODK Central credentials (url, username, password).}
\usage{
yell_if_missing(url, un, pw, pid = NULL, fid = NULL, iid = NULL)
}
\arguments{
\item{url}{A URL (character)}

\item{un}{A username (character)}

\item{pw}{A password (character)}

\item{pid}{A project ID (numeric, optional)}

\item{fid}{A form ID (character, optional)}

\item{iid}{A submission instance ID (character, optional)}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}
}
\details{
This is a helper function to pat down \code{\link{ruODK}} functions
for missing credentials and stop with a loud but informative yell.
}
\examples{
testthat::expect_error(yell_if_missing("", "username", "password"))
testthat::expect_error(yell_if_missing("url", "", "password"))
testthat::expect_error(yell_if_missing("url", "username", ""))
testthat::expect_error(yell_if_missing(NULL, "", ""))
testthat::expect_error(yell_if_missing("", "", ""))
testthat::expect_error(yell_if_missing("", "", "", ""))
testthat::expect_error(yell_if_missing("", "", "", "", ""))
testthat::expect_error(yell_if_missing("", "", "", "", "", ""))
}
\seealso{
Other ru_settings: 
\code{\link{odata_svc_parse}()},
\code{\link{parse_odkc_version}()},
\code{\link{ru_settings}()},
\code{\link{ru_setup}()},
\code{\link{semver_gt}()},
\code{\link{semver_lt}()},
\code{\link{yell_if_error}()}
}
\concept{ru_settings}
\keyword{internal}
