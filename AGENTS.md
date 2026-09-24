# AGENTS.md — ruODK

Source of truth for humans and coding agents. `CONTRIBUTING.md` governs
process; this file states the non-negotiable per-endpoint workflow.

## ODK Central API coverage

API reference: <https://docs.getodk.org/central-api/> (plus
`central-api-{accounts-and-users,project-management,form-management,submission-management,dataset-management,entity-management,system-endpoints}/`).
Function names follow ODK endpoints using the end-user alias
(`entitylist_*`, not `dataset_*`), as `object_action` snake case
(`CONTRIBUTING.md#naming-conventions`). Current coverage: ~50 of ~150
REST endpoints (Projects, Forms, Submissions, Entity Lists/Entities,
OData basics covered; Users/App Users/Assignments, Form drafts and
versions, Submission review and versions, Dataset properties, System
config/audits/backup largely missing).

## Per-endpoint implementation standard

1. **Docstrings mirror ODK docs wording.** Title, description, and
   parameter semantics follow the matching docs page verbatim where
   applicable, then add the standard ruODK structure: lifecycle badge,
   `man-roxygen` fragments, `@return`, `@family`, `@seealso` link to the
   exact docs anchor (inside `# nolint start/end`), `\dontrun{}` example.
   Any extra explanation uses Simple Technical English (ASD-STE100)
   and is clearly separated from the ODK wording.
   Never prefix with "In plain language:".
2. **Tests mirror the R function.** `tests/testthat/test-<name>.R` covers
   all feasible use cases and edge cases: happy path against the local
   Docker Central (`CONTRIBUTING.md#test`), missing/invalid parameters
   (`yell_if_missing`), version gates, empty and paged results, and
   error responses. Follow `testthat` 3e and the vendored
   `testing-r-packages` skill.
3. **Follow R package development guidelines.** Tidyverse style,
   `roxygen2` markdown at 80 cols, `devtools::document()`,
   `devtools::test()`, `devtools::check()`, `NEWS.md` bullet per
   user-facing change, `_pkgdown.yml` entry per new topic. Follow the
   vendored `r-package-development` skill and `CONTRIBUTING.md`
   checklists (naming, docs, tests, NEWS, re-check).
4. **Critical review after each implementation.** After implementing each
   endpoint (or small batch), run the vendored `critical-code-reviewer`
   skill (`.agents/skills/critical-code-reviewer/SKILL.md`), then
   address every finding before moving on.

## Practical notes

- Format touched R files with `air format` (Posit air ≥ 0.11, on PATH);
  the `air-format` pre-commit hook enforces this.
- Run `pre-commit run --files <files>` before committing.
- Test stack: `docker compose --env-file .devcontainer/.env -f
  .devcontainer/docker-compose.yml up -d --wait`, then
  `Rscript data-raw/seed_odkc.R`; `RU_VERBOSE=TRUE`.
- Vendored skills live in `.agents/skills/`; see `skills-lock.json`.
