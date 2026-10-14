#!/usr/bin/env just --justfile
# https://github.com/casey/just
# Shortcuts for ruODK development: local ODK Central test stack + R tooling.
# Run from the package root. Docker recipes assume the devcontainer
# (docker-outside-of-docker feature); R recipes assume devtools and friends.
# Unlike ckanr, secrets live in .devcontainer/.env and are passed to compose
# via --env-file, so there is no `set dotenv-load` here.

# List all recipes
default:
  @just --list

alias bs := bootstrap

# ---------------------------------------------------------------------------#
# Local ODK Central test stack (all compose traffic goes through
# .devcontainer/odkc/dc.sh, shared with postAttachCommand.sh)
# ---------------------------------------------------------------------------#

# Full bootstrap: start stack, build CA bundle, seed fixtures
bootstrap: stack_up ca_bundle stack_seed

# Start the local ODK Central stack (never recreate: shared nginx netns)
stack_up:
  # Never recreate: app shares nginx's network namespace, so recreating
  # nginx under this live container orphans our network and DNS dies.
  .devcontainer/odkc/dc.sh up -d --no-recreate --wait nginx

# Build the merged CA bundle (public CAs + local test CA)
ca_bundle:
  # libcurl replaces (not extends) its CA store from CURL_CA_BUNDLE,
  # so never point it at ca.crt on its own.
  .devcontainer/odkc/ca-bundle.sh .devcontainer/odkc/certs/ca-bundle.pem

# Seed the local Central with fixtures from inst/extdata/odkc (idempotent)
stack_seed:
  Rscript data-raw/seed_odkc.R

# Show stack status and prove the API serves HTTPS (public endpoint, no auth)
stack_status:
  .devcontainer/odkc/dc.sh ps
  curl -sk https://localhost:8383/v1/config/public | head -c 500; echo

# Tail stack logs
stack_logs:
  .devcontainer/odkc/dc.sh logs --tail 100

# Stop the local ODK Central stack
stack_stop:
  # Stop all dev services; app shares nginx's network namespace, so stopping
  # nginx alone would leave this container broken.
  .devcontainer/odkc/dc.sh stop

# Delete stray ruodk_* test junk from the local stack (asks first)
scrub:
  #!/usr/bin/env bash
  set -euo pipefail
  # Seed fixtures never use the ruodk_ prefix (Flora-Quadrat-04, Locations,
  # problems, ...), and confirmation is required, but double-check anyway.
  read -r -p "Delete all ruodk_* test forms and Entity Lists on the local stack? [y/N] " ok
  if [ "${ok}" != "y" ]; then echo "scrub aborted"; exit 0; fi
  Rscript -e '
  devtools::load_all(quiet = TRUE)
  ru_setup(pid = Sys.getenv("ODKC_TEST_PID"), url = Sys.getenv("ODKC_TEST_URL"), un = Sys.getenv("ODKC_TEST_UN"), pw = Sys.getenv("ODKC_TEST_PW"), odkc_version = Sys.getenv("ODKC_TEST_VERSION"), verbose = FALSE)
  fl <- form_list()
  for (f in fl$xml_form_id[startsWith(fl$xml_form_id, "ruodk_")]) {
    cat("del form", f, "\n")
    try(form_delete(fid = f), silent = TRUE)
  }
  el <- entitylist_list()
  for (d in el$name[startsWith(el$name, "ruodk_")]) {
    cat("del list", d, "\n")
    try(entitylist_delete(did = d), silent = TRUE)
  }
  cat("scrub done\n")
  '

# ---------------------------------------------------------------------------#
# R tooling (alternative to VS Code tasks via Ctrl-Shift-B)
# ---------------------------------------------------------------------------#

# R: Document package
doc:
  #!/usr/bin/env Rscript
  devtools::document()

# R: run tests (needs the local stack: `just bootstrap` first, RU_VERBOSE=TRUE)
test:
  #!/usr/bin/env Rscript
  devtools::test()

# R: test coverage via covr
coverage:
  #!/usr/bin/env Rscript
  devtools::test_coverage()

# R: check package
check:
  #!/usr/bin/env Rscript
  devtools::check()

# R: lint package (backstop for `just fmt`)
lint:
  #!/usr/bin/env Rscript
  lintr::lint_package()

# Format R code with air (enforced by the air-format pre-commit hook)
fmt:
  #!/usr/bin/env bash
  air format .
