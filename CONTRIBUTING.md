# Contributing
This contributing guide has been derived from the `tidyverse` boilerplate.
Where it seems over the top, common sense is appreciated, and every contribution
is appreciated.

`AGENTS.md` is authoritative for the per-endpoint implementation standard
(docstrings, tests, review gate, PR flow) and the practical notes
(formatter, lint, pre-commit). Where this document conflicts with
`AGENTS.md` on those points, `AGENTS.md` wins.

## Non-technical contributions to ruODK
Feel free to [report issues](https://github.com/ropensci/ruODK/issues):

* Bug reports are for unplanned malfunctions.
* Feature requests are for ideas and new features.

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

* Title, description, and parameter semantics from the official ODK Central
  API docs first and verbatim where applicable
* Lifecycle badge
* Additional paragraphs (see e.g. `entity_detail.R`): Factor out commonly used
  text fragments into `man-roxygen` fragments. Any extra explanation uses
  Simple Technical English (ASD-STE100), clearly separated from the ODK
  wording. Never prefix with "In plain language:".
* `@return` value
* Link the relevant ODK Central API docs and surround the link with `# nolint start / end`
  mufflers for linter warnings about the line length.
* Link to the correct reference family topic. If adding a new topic,
  update `_pkgdown.yml`.
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
* Add a commented out `# usethis::use_test("entity_detail")  # nolint` to functions
  and a commented out `# usethis::use_r("entity_detail")  # nolint` to tests.
  This serves both to create the correct files and as a convenient shortcut between both.

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
* Tests run live against the local Docker Central stack below; there are no
  recorded (vcr) cassettes to update. If the fixture set itself must change,
  re-export it with `Rscript data-raw/dump_odkc_fixtures.R` (see
  [Refreshing the fixtures](#refreshing-the-fixtures)).

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

Before changing anything, make sure the package still passes `R CMD check`
locally for you.

```r
devtools::check()
```

The full release-grade suite (`devtools::check(cran = TRUE, remote = TRUE,
incoming = TRUE)`, `rcmdcheck::rcmdcheck(args = c("--as-cran"))`,
`goodpractice::goodpractice()`, `pkgdown::build_site()`) runs at release
time via `data-raw/make_release.R`, not on every PR.

#### Style

Match the existing code style. This means you should follow the tidyverse
[style guide](http://style.tidyverse.org). Format touched R files with
`air format` (Posit air ≥ 0.11, on PATH; the `air-format` pre-commit hook
enforces this), then lint them with `lintr::lint()` and fix all findings
before committing. `air format` does not catch everything (e.g. continuation
indentation); lint is the backstop. If `air format` and lint disagree on a
construct, restructure the code so both agree.

Be careful to only make style changes to the code you are contributing. If you
find that there is a lot of code that doesn't meet the style guide, it would be
better to file an issue or a separate PR to fix that first.

```r
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
roxygen2 being used. Keep roxygen comments in Markdown at 80 columns.

For endpoint functions, the per-endpoint standard in `AGENTS.md` governs:
ODK docs wording first and verbatim where applicable, lifecycle badge,
`man-roxygen` fragments, `@return`, `@family`, `@seealso` link to the exact
docs anchor (inside `# nolint start/end`), `\dontrun{}` example. Any extra
explanation uses Simple Technical English (ASD-STE100), clearly separated
from the ODK wording. Never prefix with "In plain language:".

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

For endpoint functions, the test standard in `AGENTS.md` governs:
`tests/testthat/test-<name>.R` covers happy path against the local Docker
Central, missing/invalid parameters (`yell_if_missing`), version gates,
empty and paged results, and error responses, following `testthat` 3e and
the vendored `testing-r-packages` skill.

The test suite needs a running ODK Central. Do not use a hosted instance. The
repository ships a local one in Docker, seeded with the fixtures from
`inst/extdata/odkc/`. This is the setup that CI uses. See issue #170.

Start it and seed it:

```sh
docker compose --env-file .devcontainer/.env \
  -f .devcontainer/docker-compose.yml up -d --wait
Rscript data-raw/seed_odkc.R
```

The seed prints the `ODKC_TEST_*` values to put in your `.Renviron`. The
credentials it creates are throwaway values for a container on your machine
(`ruodk@example.com` / `ruodk-local-password`). They are not secrets.

Two details cost time if you miss them:

1. The stack serves TLS with a self-signed certificate. Point `CURL_CA_BUNDLE`
   at the merged bundle that
   `.devcontainer/odkc/ca-bundle.sh` builds. Do not point it at `ca.crt` on its
   own. `CURL_CA_BUNDLE` replaces the CA bundle of libcurl, so the local CA
   alone breaks every other `https` call from R, including CRAN.
2. `RU_VERBOSE` must be `TRUE`. `ru_msg_warn()` returns `NULL` without a
   warning when `RU_VERBOSE` is `FALSE`, so `expect_warning()` fails.

If you open the repository in a dev container or in GitHub Codespaces, step 3
above runs for you. The dev container starts the same stack and writes
`.Renviron` for you. It also installs the `opencode` CLI. To let `opencode`
use your OpenCode Go subscription there, add `OPENCODE_API_KEY` as a
**personal** Codespaces secret (`github.com/settings/codespaces`, scoped to
this repo), never as a repository secret: the dev container only picks the
token up when it is present in your own environment, so other contributors
are unaffected. With the secret present the container also defaults
`opencode` to the Go model `opencode-go/muse-spark-1.3-contributor` (unless
you already have `~/.config/opencode/opencode.json`); pick another model
with `/models`.

The image has no TeX or `qpdf`, so for in-container `R CMD check` runs skip
what needs them and let CI do the full check: `devtools::check(vignettes =
FALSE)`. Once commit churn settles, enable Codespaces Prebuilds in the repo
settings so new codespaces start from a baked image instead of compiling the
R package stack on every create.

To work against the shared `ruodk.getodk.cloud` instance instead, request an
account with an [account request issue](https://github.com/ropensci/ruODK/issues/new/choose)
and use these values in `.Renviron`:

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

##### Refreshing the fixtures

`inst/extdata/odkc/` holds an export of one ODK Central project set. Image
attachments are not in it. They come from `vignettes/media/`, which is the one
place this package keeps images and which must not change. Re-export with:

```sh
Rscript data-raw/dump_odkc_fixtures.R
```

The dump reads `ODKC_TEST_*` and is read-only. It never writes to
`vignettes/media/`.


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
```

#### Commit

When you've made your changes, format touched R files with `air format`,
fix all `lintr::lint()` findings, then run `pre-commit run --all-files`
before committing. Write a clear commit message describing what you've
done. Closing keywords (`Closes #<issue>`) go in the pull request
description, not the commit title; a `fixes #101` trailer at the end of
the commit message is also fine and closes the issue when the PR merges.

#### Push and pull

Once you've pushed your commit(s) to a branch in _your_ fork, you're ready to
make the pull request. Open one PR per endpoint (or small batch), with a
descriptive title and a comprehensive description in Simple Technical
English (ASD-STE100): what changed and why, how it was verified (tests,
live run), and `Closes #<issue>` for the issue it resolves. Never prefix
explanations with "In plain language:". You can easily view what exact
changes you are proposing using either the [Git diff](http://r-pkgs.had.co.nz/git.html#git-status)
view in RStudio, or the [branch comparison view](https://help.github.com/articles/creating-a-pull-request/)
you'll be taken to when you go to create a new PR.

#### Check the docs
Double check the output of the
[rOpenSci documentation CI](https://dev.ropensci.org/job/ruODK/lastBuild/console)
for any breakages or error messages.

#### Review, revise, repeat

After implementing each endpoint (or small batch) and before opening the
PR, run the vendored `critical-code-reviewer` skill
(`.agents/skills/critical-code-reviewer/SKILL.md`) and address every
finding.

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
The steps to prepare a new `ruODK` release are in `data-raw/make_release.R`,
summarised in `AGENTS.md#release`.
It is not necessary to run them as a contributor, but immensely convenient for
the maintainer to have them there in one place.

## Package maintenance
The code steps run by the package maintainer to prepare a release live at
`data-raw/make_release.R`. Being an R file, rather than a Markdown file like
this document, makes it easier to execute individual lines.

Pushing the Docker image requires privileged access to the Docker repository.
