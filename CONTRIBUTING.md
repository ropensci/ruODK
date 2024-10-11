# Contributing
This contributing guide has been derived from the `tidyverse` boilerplate.
Where it seems over the top, common sense is appreciated, and every contribution
is appreciated.

## Non-technical contributions to ruODK
Feel free to [report issues](https://github.com/ropensci/ruODK/issues):

* Bug reports are for unplanned malfunctions.
* Feature requests are for ideas and new features.
* Account requests are for getting access to the ODK Central instances run by DBCA
  (DBCA campaigns only) or the CI server (contributors, to run tests).

## Technical contributions to `ruODK`

If you would like to contribute to the code base, follow the process below.

*  [Prerequisites](#prerequisites)
*  [PR Process](#pr-process)
  *  [Fork, clone, branch](#fork-clone-branch)
  *  [Check](#check)
  *  [Style](#style)
  *  [Document](#document)
  *  [Test](#test)
  *  [NEWS](#news)
  *  [Re-check](#re-check)
  *  [Commit](#commit)
  *  [Push and pull](#push-and-pull)
  *  [Review, revise, repeat](#review-revise-repeat)
*   [Resources](#resources)
*   [Code of Conduct](#code-of-conduct)

This explains how to propose a change to `ruODK` via a pull request using
Git and GitHub.

For more general info about contributing to `ruODK`, see the
[Resources](#resources) at the end of this document.

### Naming conventions
ruODK names functions after ODK Central endpoints. If there are aliases, such as
"Dataset" and "Entity List", choose the alias that is shown to Central users
(here, choose "Entity List") over internally used terms.

Function names combine the object name (`project`, `form`, `submission`,
`attachment`, `entitylist`, `entity`, etc.) with the action (`list`, `detail`,
`patch`) as snake case, e.g. `project_list()`.
In case of any uncertainty, discussion is welcome.

In contrast, `pyODK` uses a class based approach with the pluralised object name
separated from the action `client.entity_lists.list()`.

Documentation should capitalise ODK Central object names: Project, Form,
Submission, Entity.

### Prerequisites
To test the package, you will need valid credentials for an existing ODK Central
instance to be used as a test server.

Before you do a pull request, you should always file an issue and make sure
the maintainers agree that it is a problem, and is happy with your basic proposal
for fixing it.
If you have found a bug, follow the issue template to create a minimal
[reprex](https://www.tidyverse.org/help/#reprex) if you can do so without
revealing sensitive information. Never include credentials in your reprex.

### Checklists
Some changes have intricate internal and external dependencies, which are easy
to miss and break. These checklists aim to avoid these pitfalls.

#### Adding a function
Discuss and agree on function naming with the `pyODK` developers.

In the function documentation, include the following components:

* Title
* Lifecycle badge
* Documentation from the official ODK Central API docs
* Additional paragraphs (see e.g. `entity_detail.R`): Factor out commonly used
  text fragments into `man-roxygen` fragments.
* Link the relevant ODK Central API docs and surround the link with `# nolint start / end` mufflers for linter warnings about the line length.
* Link to the correct reference family topic. If adding a new topic,
  update `pkgdown.yml`.
* List all parameters and export the function as usual.
* Add examples showing basic usage inside a `\dontrun{}` block. Examples have
  no access to the test server and will only work for internal helpers which
  do not access the ODK Central API.

Inside the function:

* Gatecheck for missing parameters via `yell_if_missing`.
* Gatecheck for the minimum ODK Central version.
* Prepare lengthy components of the `httr` call if it improves legibility.
* Use the native R pipe where possible. `ruODK` still re-exports the magrittr pipe.
* Parse response content as `utf-8`.
* Clean column names with `janitor::clean_names()`.

Link to tests:
* Add a commented out `# usethis::use_test("entity_detail")  # nolint` to functions and a commented out `# usethis::use_r("entity_detail")  # nolint` to tests. This serves both to create the correct files and as a convenient shortcut between both.

#### Adding a dependency
* Update DESCRIPTION
* Update GH Actions install workflows - do R package deps have system deps?
  Can GHA install them in all environments?
* Update Dockerfile
* Update binder install.R
* Update installation instructions

#### Renaming a vignette
* Search-replace all links to the vignette throughout
  * ruODK,
  * ODK Central "OData" modal
  * ODK Central docs

#### Adding or updating a test form
* Update tests
* Update examples
* Update packaged data if test form submissions are included
* Add new cassette to vcr cache for each test using the test form

#### Adding or updating package data
* Update tests using the package data
* Update examples
* Update README if showing package data

#### Adding a settings variable
* Update ru_setup, ru_settings, update and add to settings tests
* Update .Renviron
* Update GitHub secrets
* Update tic.yml (add new env vars)
* Update vignette "Setup"

### PR process

#### Fork, clone, branch

The first thing you'll need to do is to [fork](https://help.github.com/articles/fork-a-repo/)
the [`ruODK` GitHub repo](https://github.com/ropensci/ruODK), and
then clone it locally. We recommend that you create a branch for each PR.

#### Check

Before changing anything, make sure the package still passes the below listed
flavours of `R CMD check` locally for you.

```r
goodpractice::goodpractice(quiet = FALSE)
devtools::check(cran = TRUE, remote = TRUE, incoming = TRUE)
chk <- rcmdcheck::rcmdcheck(args = c("--as-cran"))
```

#### Style

Match the existing code style. This means you should follow the tidyverse
[style guide](http://style.tidyverse.org). Use the
[styler](https://CRAN.R-project.org/package=styler) package to apply the style
guide automatically.

Be careful to only make style changes to the code you are contributing. If you
find that there is a lot of code that doesn't meet the style guide, it would be
better to file an issue or a separate PR to fix that first.

```r
styler::style_pkg()
lintr:::addin_lint_package()
devtools::document(roclets = c("rd", "collate", "namespace"))
spelling::spell_check_package()
spelling::spell_check_files("README.Rmd", lang = "en_AU")
spelling::update_wordlist()
```

#### Document

We use [roxygen2](https://cran.r-project.org/package=roxygen2), specifically with the
[Markdown syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/markdown.html),
to create `NAMESPACE` and all `.Rd` files. All edits to documentation
should be done in roxygen comments above the associated function or
object. Then, run `devtools::document()` to rebuild the `NAMESPACE` and `.Rd`
files.

See the `RoxygenNote` in [DESCRIPTION](DESCRIPTION) for the version of
roxygen2 being used.

```r
spelling::spell_check_package()
spelling::spell_check_files("README.Rmd", lang = "en_AU")
spelling::update_wordlist()
codemetar::write_codemeta("ruODK")
if (fs::file_info("README.md")$modification_time <
  fs::file_info("README.Rmd")$modification_time) {
  rmarkdown::render("README.Rmd", encoding = "UTF-8", clean = TRUE)
  if (fs::file_exists("README.html")) fs::file_delete("README.html")
}
```

#### Test

We use [testthat](https://cran.r-project.org/package=testthat). Contributions
with test cases are easier to review and verify.

To run tests and build the vignettes, you'll need access to the
[ruODK test server](https://odkc.dbca.wa.gov.au/).
If you haven't got an account yet, create an [accont request issue](https://github.com/ropensci/ruODK/issues/new/choose)
to request access to this ODK Central instance.

The tests require the following additions to your `.Renviron`:

```r
# ODK Test server
ODKC_TEST_SVC="https://ruodk.getodk.cloud/v1/projects/1/forms/Flora-Quadrat-04.svc"
ODKC_TEST_URL="https://ruodk.getodk.cloud"
ODKC_TEST_PID=1
ODKC_TEST_PID_ENC=2
ODKC_TEST_PP="ThePassphrase"
ODKC_TEST_FID="Flora-Quadrat-04"
ODKC_TEST_FID_ZIP="Locations"
ODKC_TEST_FID_ATT="Flora-Quadrat-04-att"
ODKC_TEST_FID_GAP="Flora-Quadrat-04-gap"
ODKC_TEST_FID_WKT="Locations"
ODKC_TEST_FID_I8N0="I8n_no_lang"
ODKC_TEST_FID_I8N1="I8n_label_lng"
ODKC_TEST_FID_I8N2="I8n_label_choices"
ODKC_TEST_FID_ENC="Locations"
ODKC_TEST_VERSION="2023.5.1"
RU_VERBOSE=TRUE
RU_TIMEZONE="Australia/Perth"
RU_RETRIES=3
ODKC_TEST_UN="..."
ODKC_TEST_PW="..."

# Your ruODK default settings for everyday use
ODKC_URL="..."
ODKC_PID=1
ODKC_FID="..."
ODKC_UN="..."
ODKC_PW="..."
```

Keep in mind that `ruODK` defaults to use `ODKC_{URL,UN,PW}`, so for everyday
use outside of contributing, you will want to use your own `ODKC_{URL,UN,PW}`
account credentials.

```r
devtools::test()
devtools::test_coverage()
```

#### NEWS

For user-facing changes, add a bullet to `NEWS.md` that concisely describes
the change. Small tweaks to the documentation do not need a bullet. The format
should include your GitHub username, and links to relevant issue(s)/PR(s), as
seen below.

```md
* `function_name()` followed by brief description of change (#issue-num, @your-github-user-name)
```

#### Re-check

Before submitting your changes, make sure that the package either still
passes `R CMD check`, or that the warnings and/or notes have not _changed_
as a result of your edits.

```r
devtools::check()
goodpractice::goodpractice(quiet = FALSE)
```

#### Commit

When you've made your changes, write a clear commit message describing what
you've done. If you've fixed or closed an issue, make sure to include keywords
(e.g. `fixes #101`) at the end of your commit message (not in its
title) to automatically close the issue when the PR is merged.

#### Push and pull

Once you've pushed your commit(s) to a branch in _your_ fork, you're ready to
make the pull request. Pull requests should have descriptive titles to remind
reviewers/maintainers what the PR is about. You can easily view what exact
changes you are proposing using either the [Git diff](http://r-pkgs.had.co.nz/git.html#git-status)
view in RStudio, or the [branch comparison view](https://help.github.com/articles/creating-a-pull-request/)
you'll be taken to when you go to create a new PR. If the PR is related to an
issue, provide the issue number and slug in the _description_ using
auto-linking syntax (e.g. `#15`).

#### Check the docs
Double check the output of the
[rOpenSci documentation CI](https://dev.ropensci.org/job/ruODK/lastBuild/console)
for any breakages or error messages.

#### Review, revise, repeat

The latency period between submitting your PR and its review may vary.
When a maintainer does review your contribution, be sure to use the same
conventions described here with any revision commits.

### Resources

*  [Happy Git and GitHub for the useR](http://happygitwithr.com/) by Jenny Bryan.
*  [Contribute to the tidyverse](https://www.tidyverse.org/contribute/) covers
   several ways to contribute that _don't_ involve writing code.
*  [Contributing Code to the Tidyverse](http://www.jimhester.com/2017/08/08/contributing/) by Jim Hester.
*  [R packages](http://r-pkgs.had.co.nz/) by Hadley Wickham.
   *  [Git and GitHub](http://r-pkgs.had.co.nz/git.html)
   *  [Automated checking](http://r-pkgs.had.co.nz/check.html)
   *  [Object documentation](http://r-pkgs.had.co.nz/man.html)
   *  [Testing](http://r-pkgs.had.co.nz/tests.html)
*  [dplyr’s `NEWS.md`](https://github.com/tidyverse/dplyr/blob/master/NEWS.md)
   is a good source of examples for both content and styling.
*  [Closing issues using keywords](https://help.github.com/articles/closing-issues-using-keywords/)
   on GitHub.
*  [Autolinked references and URLs](https://help.github.com/articles/autolinked-references-and-urls/)
   on GitHub.
*  [GitHub Guides: Forking Projects](https://guides.github.com/activities/forking/).

### Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to
abide by its terms.

## Maintaining `ruODK`
The steps to prepare a new `ruODK` release are in `data-raw/make_release.R`.
It is not necessary to run them as a contributor, but immensely convenient for
the maintainer to have them there in one place.

## Package maintenance
The code steps run by the package maintainer to prepare a release live at
`data-raw/make_release.R`. Being an R file, rather than a Markdown file like
this document, makes it easier to execute individual lines.

Pushing the Docker image requires privileged access to the Docker repository.
