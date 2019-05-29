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
