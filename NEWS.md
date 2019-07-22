# ruODK 0.3.0
* Use tidyverse issue template
* Follow `goodpractice`
* Created vignette "Setup"
* Started on REST API: `form_list`, `project_list`, `project_detail`. Naming
  scheme is `object_verb`. For now, functions related to the OData endpoint
  are named `verb_object`, maybe we should rename them to `odata_object_verb`.
* Refactor URLs - build from project and form IDs

# ruODK 0.2.4
* Cleaned up logo, thanks to @issa-tseng for suggestions

# ruODK 0.2.3
* Added a new form, Flora Quadrat 0.3 to inst/extdata.

# ruODK 0.2.2
* Added more test coverage.

# ruODK 0.2.1
* Added various `usethis` goodies, test stubs, badges.

# ruODK 0.2.0
* Recursively unnests raw data into wide format. Manual post-processing is still
  required to rename (anonymous in ODK and auto-named through R) coordinates,
  and to handle attachments.

# ruODK 0.1.0
* Parses metadata, submissions, 
  and handles attachments (retaining already downloaded attachments).
* Includes example forms as both `.xml` and `.odbbuild` in `inst/extdata`.
* Includes example data as retrieved from ODK Central.
* Includes vignette demonstrating tidying of retrieved data.
* Handles repeating groups.

Roadmap:

* Handle paginated submissions.
* Retain already downloaded submissions.
