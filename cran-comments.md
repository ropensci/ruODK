## Test environments

* local R installation, R 4.6.1 on Ubuntu 24.04 (rocker `r-ver`
  devcontainer)
* GitHub Actions (ubuntu-latest, R release):
  `.github/workflows/R-CMD-check.yaml` starts a local ODK Central in
  Docker and runs the full test suite against it (see issue #170)

## R CMD check results

0 errors | 0 warnings | 1 note

This is the first CRAN submission of this package.

The single NOTE (`checking CRAN incoming feasibility`) lists URLs that
are either fictional illustration URLs or third-party badges:

* `https://example.com` and `https://example.net` in
  `vignettes/setup.Rmd` are fictional ODK Central hosts in `eval=FALSE`
  documentation chunks; they 404 by design.
* Moved badge URLs (`codecov.io` to `app.codecov.io`, one dead `tic`
  workflow badge, one moved `travis-ci.org` badge) and `r-pkg.org`
  badge images for third-party packages in `vignettes/comparison.Rmd`
  are maintained outside this package and will be refreshed separately.
* `https://docs.ropensci.org/ruODK/` redirects inside the project site.

Environments without a TeX installation additionally report the PDF
manual ERROR/WARNING, the `tidy` NOTE and the `ruODK-manual.tex` NOTE;
CRAN has a full TeX installation, so these do not apply.

## First submission notes

* All examples that need a live ODK Central server run in `\dontrun{}`.
  The test suite skips entirely without the `ODKC_TEST_URL` environment
  variable (`tests/testthat.R`); CI provides it through a local Docker
  stack, so tests run there.
* There are no published references describing the methods in this
  package: it implements an original 'R' client for the 'ODK Central'
  API.
* The `Remotes` field in DESCRIPTION points at development versions of
  the 'r-spatial' packages 'leafem' and 'mapview'; it is only used by
  development tooling and is ignored by CRAN.
