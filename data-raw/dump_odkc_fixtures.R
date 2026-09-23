#!/usr/bin/env Rscript
# Dump the shared ODK Central test server (ruodk.getodk.cloud) to local
# fixtures, for replay against the containerised ODK Central in
# .devcontainer/docker-compose.yml. See issue #170.
#
# Run from the package root:
#   Rscript data-raw/dump_odkc_fixtures.R
#
# Reads ODKC_TEST_* from the environment / ~/.Renviron (see CONTRIBUTING.md).
# Writes inst/extdata/odkc/ (R package convention for shipped data files).
#
# That subdirectory is deliberate: inst/extdata also holds the hand-maintained
# form sources (FloraQuadrat04.xml, Locations.xml, ...) whose paths are
# documented as @source in R/data.R. The dump writes only inside odkc/, so a
# dumped Locations.xml can never overwrite the hand-maintained one.
#
# FORM XML ONLY. The XLS sources are not dumped: the XML is the compiled form
# and POST /v1/projects/{pid}/forms accepts it directly, so XLS would add 1.6MB
# to the installed package for nothing. Re-add them if a pyxform publish path
# is ever wanted.
#
# IMAGES ARE NOT COPIED. Image attachment bytes are served from
# vignettes/media/, which is the single point of images in this package and
# must not change. The dump only records which vignettes/media file stands in
# for which attachment name (see attachments-map.json).
#
# Non-image attachments (e.g. the encrypted form's submission.xml.enc, or
# stray .bin payloads) are NOT images and have no vignette counterpart, so
# their bytes ARE copied into submissions/<pid>/<fid>/<slug>/.
#
# Read-only against the server. Re-run any time the server fixture set drifts.

suppressMessages({
  library(ruODK)
  library(dplyr)
  library(purrr)
  library(fs)
  library(jsonlite)
  library(xml2)
})

# --------------------------------------------------------------------------- #
# Config
# --------------------------------------------------------------------------- #

fixture_root <- path("inst", "extdata", "odkc")
media_dir <- path("vignettes", "media")
extdata_dir <- path("inst", "extdata")

cfg <- list(
  url = ruODK::get_test_url(),
  un = ruODK::get_test_un(),
  pw = ruODK::get_test_pw(),
  pp = ruODK::get_test_pp(),
  retries = 2,
  odkc_version = ruODK::get_test_odkc_version()
)
if (!nzchar(cfg$url) || !nzchar(cfg$un) || !nzchar(cfg$pw)) {
  stop("ODKC_TEST_URL / ODKC_TEST_UN / ODKC_TEST_PW must be set. See ~/.Renviron.")
}

api <- function(...) {
  do.call(httr::RETRY, c(
    list(
      ...,
      httr::authenticate(cfg$un, cfg$pw),
      times = cfg$retries
    )
  ))
}

say <- function(...) cat(sprintf(...), "\n", sep = "")

# The PIDs actually exercised by tests/. Anything else on the server is
# incidental and is not dumped (Sandbox = pid 3).
pids <- c(
  as.integer(Sys.getenv("ODKC_TEST_PID", "1")),
  as.integer(Sys.getenv("ODKC_TEST_PID_ENC", "2"))
)

# ruODK's submission_list() errors on forms with zero submissions (it selects a
# `submitter` column that is absent from an empty result). Treat that as "no
# submissions" rather than aborting the dump.
safe_submission_list <- function(pid, fid) {
  tryCatch(
    ruODK::submission_list(
      pid = pid, fid = fid,
      url = cfg$url, un = cfg$un, pw = cfg$pw,
      retries = cfg$retries
    ),
    error = function(e) {
      say("      note: submission_list(%s/%s) -> %s (treating as 0 rows)",
          pid, fid, conditionMessage(e))
      tibble::tibble(instance_id = character(0))
    }
  )
}

# --------------------------------------------------------------------------- #
# Start clean
# --------------------------------------------------------------------------- #

say("dumping %s -> %s", cfg$url, fixture_root)

# Refuse to run if anything outside the odkc/ subdirectory would be touched.
# inst/extdata holds hand-maintained form sources documented in R/data.R.
protected <- dir_ls(extdata_dir, type = "file") |> path_file()
collisions <- intersect(protected, c("manifest.json", "attachments-map.json"))
if (length(collisions) > 0) {
  stop("dump output would collide with existing inst/extdata files: ",
       paste(collisions, collapse = ", "))
}
say("  inst/extdata has %d protected file(s); dump writes only into odkc/",
    length(protected))

if (dir_exists(fixture_root)) {
  say("  removing previous dump at %s", fixture_root)
  dir_delete(fixture_root)
}
dir_create(path(fixture_root, "forms"))
dir_create(path(fixture_root, "submissions"))

# Snapshot vignettes/media so we can map attachment names onto it without
# ever writing into it.
media_files <- dir_ls(media_dir, regexp = "\\.(jpg|jpeg|png)$", type = "file")
if (length(media_files) == 0) stop("no images found in ", media_dir)
media_names <- path_file(media_files)
say("  vignettes/media has %d image(s): %s",
    length(media_names), paste(media_names, collapse = ", "))

# Image attachment name -> vignettes/media basename. Exact filename match
# wins; any other image name cycles through media_names in sorted order.
# Recorded in attachments-map.json so the choice is deterministic and
# reviewable. Non-image attachments never come from vignettes/media.
media_state <- new.env(parent = emptyenv())
media_state$cursor <- 0L
is_image <- function(name) grepl("\\.(jpg|jpeg|png)$", name, ignore.case = TRUE)
pick_media <- function(attachment_name) {
  if (attachment_name %in% media_names) return(attachment_name)
  media_state$cursor <- media_state$cursor + 1L
  media_names[[((media_state$cursor - 1L) %% length(media_names)) + 1L]]
}

# Filesystem slug for a submission instance id. The full instance id is
# "uuid:" plus 32 hex characters, which makes paths longer than the 100 bytes
# that tar can store portably. `R CMD build` warns for each one. The first 8
# hex characters are enough to tell 19 submissions apart, and the full id stays
# in manifest.json as the key of submissions_detail.
slug_of <- function(iid) substr(sub("^uuid:", "", iid), 1, 8)

manifest <- list(
  source = cfg$url,
  dumped_at = format(Sys.time(), tz = "UTC", usetz = TRUE),
  odkc_version_declared = Sys.getenv("ODKC_TEST_VERSION", ""),
  notes = c(
    "Image attachment BYTES are not stored here. See attachments-map.json:",
    "each image filename maps to a file in vignettes/media/, which is the",
    "single point of images in this package and must not be modified.",
    "Non-image attachments are copied under submissions/<pid>/<fid>/<slug>/.",
    "XLS form sources are not stored; see had_xls per form in this manifest."
  ),
  projects = list()
)
attachment_map <- list()

# --------------------------------------------------------------------------- #
# Dump
# --------------------------------------------------------------------------- #

for (pid in pids) {
  say("\n=== pid %d ===", pid)
  proj_meta <- ruODK::project_list(
    url = cfg$url, un = cfg$un, pw = cfg$pw, retries = cfg$retries
  ) |> filter(.data$id == pid)
  proj <- list(
    id = pid,
    name = proj_meta$name[[1]],
    description = if ("description" %in% names(proj_meta)) proj_meta$description[[1]] else NULL,
    key_id = if ("key_id" %in% names(proj_meta)) proj_meta$key_id[[1]] else NULL,
    forms = list()
  )
  say("  project: %s", proj$name)

  fl <- ruODK::form_list(
    pid = pid, url = cfg$url, un = cfg$un, pw = cfg$pw, retries = cfg$retries
  )
  say("  %d form(s)", nrow(fl))
  dir_create(path(fixture_root, "forms", as.character(pid)))

  for (i in seq_len(nrow(fl))) {
    fid <- fl$xml_form_id[[i]]
    is_draft <- is.na(fl$published_at[[i]])
    say("\n  -- %s%s", fid, if (is_draft) "  [DRAFT]" else "")

    # --- form XML, verbatim ---------------------------------------------
    # For the encrypted form this carries <submission base64RsaPublicKey="...">
    # as an attribute, so replaying the same XML restores the same public key.
    raw <- api(
      "GET",
      httr::modify_url(cfg$url, path = glue::glue(
        "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}.xml"
      )),
      httr::add_headers(Accept = "application/xml")
    )
    httr::stop_for_status(raw)
    xml_text <- httr::content(raw, as = "text", encoding = "UTF-8")
    xml_path <- path(fixture_root, "forms", as.character(pid), paste0(fid, ".xml"))
    writeLines(xml_text, xml_path, useBytes = TRUE)
    say("      form.xml %d bytes", nchar(xml_text))

    # XLS sources are deliberately not dumped. The XML above is the compiled
    # form and is sufficient to republish; keeping the XLS would add 1.6MB to
    # the installed package. manifest.json records whether the live form had
    # one (excel_content_type) so the gap is visible.
    xls_path <- NULL

    # --- submissions ------------------------------------------------------
    sl <- safe_submission_list(pid, fid)
    say("      %d submission(s)", nrow(sl))
    if (nrow(sl) > 0) {
      dir_create(path(fixture_root, "submissions", as.character(pid), fid))
    }

    subs <- list()
    for (j in seq_len(nrow(sl))) {
      iid <- sl$instance_id[[j]]
      slug <- slug_of(iid)
      # submission_list() orders by createdAt DESC, so this is newest-first.
      # Recorded so the seed can replay in reverse and preserve the relative
      # submission dates (Central stamps createdAt itself at ingest).
      created_rank <- j
      sxml <- api(
        "GET",
        httr::modify_url(cfg$url, path = glue::glue(
          "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}/",
          "submissions/{URLencode(iid, reserved = TRUE)}.xml"
        )),
        httr::add_headers(Accept = "application/xml")
      )
      httr::stop_for_status(sxml)
      sxml_text <- httr::content(sxml, as = "text", encoding = "UTF-8")
      sub_dir <- path(fixture_root, "submissions", as.character(pid), fid)
      writeLines(sxml_text, path(sub_dir, paste0(slug, ".xml")), useBytes = TRUE)

      # --- attachments: images -> vignettes/media stand-in; other bytes copied
      al <- tryCatch(
        ruODK::attachment_list(
          iid = iid, pid = pid, fid = fid,
          url = cfg$url, un = cfg$un, pw = cfg$pw, retries = cfg$retries
        ),
        error = function(e) tibble::tibble(name = character(0))
      )
      att <- list()
      for (k in seq_len(nrow(al))) {
        nm <- al$name[[k]]
        if (is_image(nm)) {
          stand_in <- pick_media(nm)
          att[[nm]] <- list(
            source = "media",
            path = file.path("vignettes", "media", stand_in),
            exact_name_match = nm == stand_in
          )
          attachment_map[[nm]] <- c(
            att[[nm]],
            list(pid = pid, fid = fid, instance_id = iid)
          )
          say("        img %-34s -> %s%s", nm, stand_in,
              if (nm == stand_in) "" else "  (name cycled)")
        } else {
          # Not an image: no vignette counterpart, so keep the real bytes.
          payload <- api(
            "GET",
            httr::modify_url(cfg$url, path = glue::glue(
              "v1/projects/{pid}/forms/{URLencode(fid, reserved = TRUE)}/",
              "submissions/{URLencode(iid, reserved = TRUE)}/",
              "attachments/{URLencode(nm, reserved = TRUE)}"
            ))
          )
          httr::stop_for_status(payload)
          att_dir <- path(sub_dir, slug)
          dir_create(att_dir)
          writeBin(httr::content(payload, as = "raw"), path(att_dir, nm))
          rel <- path_rel(path(att_dir, nm), start = ".")
          att[[nm]] <- list(source = "fixture", path = as.character(rel))
          attachment_map[[nm]] <- c(
            att[[nm]],
            list(pid = pid, fid = fid, instance_id = iid)
          )
          say("        bin %-34s -> copied (%s, %d bytes)", nm, rel,
              file_size(path(att_dir, nm)))
        }
      }
      subs[[iid]] <- list(
        # Filesystem slug for this submission. Full instance id is the key of
        # this entry. See slug_of() above.
        slug = slug,
        # submission_list() gives review_state; NA on the server means nobody
        # has reviewed it. The seed replays this or class(review_state) comes
        # back logical (all-NA) instead of character, which
        # test-submission_list.R asserts against.
        review_state = if (is.null(sl$review_state) ||
                             is.na(sl$review_state[[j]])) {
          NULL
        } else {
          sl$review_state[[j]]
        },
        newest_first_rank = created_rank,
        attachments = att
      )
    }

    proj$forms[[fid]] <- list(
      xml_form_id = fid,
      name = fl$name[[i]],
      version = if (is.na(fl$version[[i]])) NULL else fl$version[[i]],
      state = fl$state[[i]],
      is_draft = is_draft,
      published_at = if (is.na(fl$published_at[[i]])) NULL else fl$published_at[[i]],
      hash = fl$hash[[i]],
      submissions = nrow(sl),
      entity_related = isTRUE(fl$entity_related[[i]]),
      # TRUE on the live server means an XLS was uploaded; that source is not
      # dumped (see header), so this records the gap.
      had_xls = !is.na(fl$excel_content_type[[i]]) &&
        nzchar(fl$excel_content_type[[i]]),
      submission_instances = names(subs),
      submissions_detail = subs
    )
  }

  # --- entity lists --------------------------------------------------------
  el <- tryCatch(
    ruODK::entitylist_list(
      pid = pid, url = cfg$url, un = cfg$un, pw = cfg$pw,
      retries = cfg$retries, odkc_version = cfg$odkc_version
    ),
    error = function(e) {
      say("  entitylist_list -> %s", conditionMessage(e))
      NULL
    }
  )
  if (!is.null(el) && nrow(el) > 0) {
    say("\n  %d entity list(s)", nrow(el))
    proj$entity_lists <- list()
    for (i in seq_len(nrow(el))) {
      did <- el$name[[i]]
      d <- tryCatch(
        ruODK::entitylist_detail(
          pid = pid, did = did, url = cfg$url, un = cfg$un, pw = cfg$pw,
          retries = cfg$retries, odkc_version = cfg$odkc_version
        ),
        error = function(e) NULL
      )
      en <- tryCatch(
        ruODK::entity_list(
          pid = pid, did = did, url = cfg$url, un = cfg$un, pw = cfg$pw,
          retries = cfg$retries, odkc_version = cfg$odkc_version
        ),
        error = function(e) tibble::tibble()
      )
      # Entities are created by replaying entity-form submissions, so we only
      # record the shape here -- not the full 354 rows. No test asserts a count.
      say("    %s: %d live entities (schema only is dumped)", did, nrow(en))
      proj$entity_lists[[did]] <- list(
        name = did,
        properties = if (is.null(d)) NULL else d$properties,
        linked_forms = if (is.null(d)) NULL else d$linked_forms,
        source_forms = if (is.null(d)) NULL else d$source_forms,
        live_entity_count = nrow(en),
        entity_columns = names(en)
      )
    }
  }

  manifest$projects[[as.character(pid)]] <- proj
}

# --------------------------------------------------------------------------- #
# Write manifests
# --------------------------------------------------------------------------- #

# Fail loudly rather than overwrite one submission with another. Unlikely at
# 8 hex characters, and the full instance id is still the manifest key.
all_iids <- unlist(lapply(manifest$projects, function(p) {
  unlist(lapply(p$forms, function(f) f$submission_instances))
}))
all_slugs <- slug_of(all_iids)
if (anyDuplicated(all_slugs) > 0) {
  dupes <- unique(all_slugs[duplicated(all_slugs)])
  stop(
    "8-character submission slugs collide for: ",
    paste(all_iids[all_slugs %in% dupes], collapse = ", "),
    ". Widen slug_of() before re-running."
  )
}
say("submission slugs: %d unique of %d", length(unique(all_slugs)), length(all_slugs))

write_json(
  attachment_map,
  path(fixture_root, "attachments-map.json"),
  auto_unbox = TRUE, pretty = TRUE
)
write_json(
  manifest,
  path(fixture_root, "manifest.json"),
  auto_unbox = TRUE, pretty = TRUE, null = "null"
)

# --------------------------------------------------------------------------- #
# Summary
# --------------------------------------------------------------------------- #

files <- dir_ls(fixture_root, recurse = TRUE, type = "file")
say("\n=================================================")
say("dumped %d file(s), %s total", length(files), as.character(sum(file_size(files))))
say("  %s", path_rel(files))
say("")
say("attachment sources: %d mapped", length(attachment_map))
src <- map_chr(attachment_map, "source")
say("  images -> vignettes/media : %d   (vignettes/media is the single image source)",
    sum(src == "media"))
say("  bytes copied to fixtures  : %d   (non-images; no vignette counterpart)",
    sum(src == "fixture"))
exact <- map_lgl(attachment_map[src == "media"], function(x) isTRUE(x$exact_name_match))
say("  of those images, exact filename match: %d, name cycled: %d",
    sum(exact), sum(!exact))
say("")
say("vignettes/media untouched? -> %s",
    if (dir_exists(media_dir)) "yes (write target is fixtures/ only)" else "NO")
say("inst/extdata (non-odkc/) untouched? -> %s",
    if (length(setdiff(protected, c("manifest.json", "attachments-map.json"))) ==
          length(protected)) {
      "yes (dump writes only into odkc/)"
    } else {
      "NO"
    })
say("done.")
