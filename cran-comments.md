## Test environments
* Local machine
  * Running under: Ubuntu 20.04.2 LTS
  * Platform: x86_64-pc-linux-gnu (64-bit)
  * R version 4.0.4 (2021-02-15)
* AppVeyor CI
  * Running under: Windows Server 2012 R2 x64 (build 9600)
  * Platform: x86_64-w64-mingw32/x64 (64-bit)
  * R version 4.0.3 Patched (2020-11-08 r79411)
* GitHub Actions: R devel, release, oldrel for each of
  * Windows-latest (Windows Server 2019)
  * Windows Server 2016
  * MacOS-lastest (MacOS X Catalina 10.05)
  * Ubuntu 20.04
  * Ubuntu 18.04

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

Resolved NOTE comments:
* Possibly invalid URLs:
  * The package comparison section in the README contains Markdown badges with
    CRAN links to packages that are not yet or not any more on CRAN. These
    links are correct, and while they currently do not resolve, they will do so
    once the packages are (re-)submitted to CRAN. Currently removed.
  * The README contains an ODK Central form OData service URL to illustrate
    setting up ruODK. The URL redirects to a login screen if followed directly.
    This is expected behaviour. Currently not appearing as warning.
* The PDF version of the manual is now included.
* The example data contains UTF-8 strings. This is a realistic scenario.
  The note has disappeared after the R version 4 release.
* Test coverage: All functionality supporting the current ODK Central release is
  covered by tests.
  The only exception is `form_schema{_parse}`, which supports a breaking
  change between ODK Central 0.7 and 0.8. The test server runs ODK Central 0.8,
  a production server (used by the package author, but not accessible to other
  maintainers) runs 0.7 successfully. The tests for v 0.7 use packaged data.
