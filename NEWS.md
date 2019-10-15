# `ruODK` (development version)
This version addresses ROpenSci reviewer comments from @karissawhiting.

## Major fixes

## Minor fixes
* Drop `. <- NULL` in favour of `utils::globalVariables(".")` (#35)
* Print settings now hides passwords but instructs how to show them. (#37)
* `ru_setup()` now prints settings. (#37)

## Dependencies
* Moved `rlist` to Imports, as it is now used in `odata_submission_get()` (#6)
* Use development versions of `rlang`, `purrr` and `lifecycle` to get their
  latest bug fixes.

## Data

## Documentation
* Updated workshop companion package [urODK](https://github.com/dbca-wa/urODK)


# `ruODK` 0.6.6
* The big one has landed: `odata_submission_get()` now defaults to parse 
  submissions from nested lists into a tibble, parse dates and datetimes,
  download and link attachments (#6)

# `ruODK` 0.6.5
## Documentation
* Use lifecycle badges on functions. Add lifecycle to dependencies, version bump
  `usethis` (#29)
  
## Code
* Refactor list wrangling code to use `map_*(.default=NA)`, removing some 
  internal helpers (thanks to @jennybc)
* Use dummy imports to silence R CMD check NOTES as per [googledrive](https://github.com/tidyverse/googledrive/blob/050a982cba630503702bdde05a77d727baa36d48/R/googledrive-package.R)'s example (thanks to @jennybc)
* Drop unused internal helper functions

# `ruODK` 0.6.4
## Data
*  Use three new test forms to make package smaller and tests faster.
   Use the main test form for example data, including data from two nested tables.
   Use the main test form in all vignettes and README.
   Use a small form without attachments for tests repeatedly exporting to ZIP.
   Use another small form with only one submission and two attachments for tests
   downloading attachments.
   The test credentials are unchanged (#23)

# `ruODK` 0.6.3
## Dependencies
*  [tidyr 1.0.0](https://www.tidyverse.org/articles/2019/09/tidyr-1-0-0/) is out!
  Move `{tidyr}` dependency from GitHub master to CRAN version (#27)
*  Add `{usethis}` to Suggests, it is used in the setup step
  
## Documentation
*  Add [David Henry](https://github.com/schemetrica)'s 
  [Pentaho Kettle tutorial](https://forum.opendatakit.org/t/automating-data-delivery-using-the-odata-endpoint-in-odk-central/22010) 
  to the software review in the README (#28)
  
## DIY for workshops
*  Add inaugural RMarkdown template "odata" (#26)
*  Add [binder](https://mybinder.org/) launch button (one click start for #26)

# `ruODK` 0.6.2
## Code
*  Simplifiy `ru_setup()` to use OData Service URL.
*  Change all functions to default to `get_default{pid,fid,url,un,pw}()`, partly
  moving project ID (pid) and form ID (fid) to kwargs. This changes all examples,
  tests, vignettes, READMEs.
*  Reduce installed package size by sharing attachment files. Add new parameter
  `separate=FALSE` to `attachment_get` to prevent separating attachment files 
  into subfolders named after their submission `uuid` (#22)
  
## Documentation
*  Add a high level overview diagram to README and `inst/joss/paper.md` to
  illustrate `ruODK`'s intended purpose in the ODK ecosystem (#19)
*  Added link to explain 
  [environment variables and R startup](https://whattheyforgot.org/r-startup.html) 
  to vignette "setup". @maelle
*  Add comparison of similar software to README (#25)

# `ruODK` 0.6.1
*  ROpenSci submission review [milestone](https://github.com/dbca-wa/ruODK/milestone/3), 
  [discussion](https://github.com/ropensci/software-review/issues/335).
*  Updates to documentation (#13 #15 #17)
*  Group function docs (#18)
*  Update contribution guidelines and add account request issue template:
  How to run `ruODK` tests and build the vignettes (#15 #20)
*  Add dedicated `ru_setup()` and `ru_settings()`. 
  Pat down functions for missing credentials and yell loudly but clearly about
  httr errors. (#16)
*  Drop `@importFrom` to reduce duplication. All external functions are prefixed
  with their package name already.
*  Add convenience helpers `attachment_link()` and `parse_datetime()`.
*  Use `janitor::clean_names()` on column names over home-grown helpers.
*  Since `submission_detail` is now metadata only, add `submission_get` to download
  submission data.

# `ruODK` 0.6.0
*  Version bump and lifecycle bump to indicate that `ruODK` is ready to be used
  against ODK Central 0.6.

# `ruODK` 0.6.0.9000
*  Version bump to match ODK Central's version.
*  Updated to match ODK Central's API at 0.6 (RESTful and OData) (c.f.).
*  Add commented out crosslinks to source code and related tests for convenience.
*  Encryption endpoints (new in 0.6) are not yet supported.
*  Audit logs supported, as they are a read-only export.

# `ruODK` 0.3.1
## Preparation for ROpenSci pre-submission
*  Check name with [`available::available("ruODK")`](https://devguide.ropensci.org/building.html#naming-your-package):
  *  Name valid: ✔
  *  Available on CRAN: ✔ 
  *  Available on Bioconductor: ✔
  *  Available on GitHub:  ✔ 
  *  Rude misinterpretations: none
  *  In summary: Package name seems to be OK. Well, ODK. OK, ruODK.
*  Added metadata via 
  [`codemetar::write_codemeta("ruODK")`](https://devguide.ropensci.org/building.html#creating-metadata-for-your-package).
*  [Cross-platform](https://devguide.ropensci.org/building.html#platforms): 
  Runs on GNU/Linux (TravisCI) and on Windows (AppVeyor)
*  [Function naming](https://devguide.ropensci.org/building.html#function-and-argument-naming)
  follows `object_verb`. 
  *  `ruODK` uses verb singulars (e.g. `submission_list` to 
  list multiple submissions), while ODK Central's API URLs use verb plurals.
  *  `ruODK` uses `snake_case`.
  *  Exception to `object_verb`: 
    Functions operating on the OData endpoints are named `odata_object_verb`.
    Helper functions not related to API endpoints are named `verb_object`. 
*  [Code style](https://devguide.ropensci.org/building.html#code-style) done
  by `styler::style_package()`, see section "Release" in `README.md`.
*  `ruODK` [has a `README.Rmd`](https://devguide.ropensci.org/building.html#readme) 
  and has a 
  [website generated by `pkgdown`](https://devguide.ropensci.org/building.html#website).
*  `ruODK` has documentation 
  [generated by `roxygen2`](https://devguide.ropensci.org/building.html#documentation).
*  [Test coverage](https://devguide.ropensci.org/building.html#testing) 100%, but
  could use more edge cases.
*  Tests use a live ODK Central instance, which is kept up to date by ODK.
  This means that ruODK's test always run against the latest master of ODK Central.
  `ruODK` does not (but maybe should?) use `webmockr` and `vcr`.
*  Spellchecks with `spelling::spell_check_package()`: added technical terms and
  function names to `inst/WORDLIST`.
*  Added citation and section in `README`.
*  Added `inst/joss/paper.md` for submission to JOSS.
*  Added [examples](https://devguide.ropensci.org/building.html#examples) to 
  function docs.

## TODO
*  Implement remaining missing functions ([ticket](https://github.com/dbca-wa/ruODK/issues/9)).

# `ruODK` 0.3.0
*  Use tidyverse issue template
*  Follow `goodpractice`
*  Created vignette "Setup"
*  Add AppVeyor
*  Refactor storage path of attachments to not contain "uuid:" (for Windows compat)
*  Started on REST API: `project_list`, `project_detail`, `form_list`, 
  `form_detail`. Naming scheme is `object_verb`. 
*  For now, functions related to the OData endpoint
  are named `verb_object`, maybe we should rename them to `odata_object_verb`.
*  Refactor URLs - build from project and form IDs
  
# `ruODK` 0.2.4
*  Cleaned up logo, thanks to @issa-tseng for suggestions

# `ruODK` 0.2.3
*  Added a new form, Flora Quadrat 0.3 to inst/extdata.

# `ruODK` 0.2.2
*  Added more test coverage.

# `ruODK` 0.2.1
*  Added various `usethis` goodies, test stubs, badges.

# `ruODK` 0.2.0
*  Recursively unnests raw data into wide format. Manual post-processing is still
  required to rename (anonymous in ODK and auto-named through R) coordinates,
  and to handle attachments.

# `ruODK` 0.1.0
*  Parses metadata, submissions, 
  and handles attachments (retaining already downloaded attachments).
*  Includes example forms as both `.xml` and `.odbbuild` in `inst/extdata`.
*  Includes example data as retrieved from ODK Central.
*  Includes vignette demonstrating tidying of retrieved data.
*  Handles repeating groups.

Roadmap:

*  Handle paginated submissions.
*  Retain already downloaded submissions.
