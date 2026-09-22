#!/usr/bin/env Rscript
# Seed a local ODK Central with the fixtures dumped by
# data-raw/dump_odkc_fixtures.R. See issue #170.
#
# Run from the package root, with the test stack up:
#   docker compose --env-file .devcontainer/.env -f .devcontainer/docker-compose.yml up -d --wait
#   Rscript data-raw/seed_odkc.R
#
# Reads:
#   inst/extdata/odkc/            forms (XML), submissions (XML), manifest.json,
#                                 attachments-map.json, non-image attachment bytes
#   vignettes/media/              ALL image attachment bytes. This is the single
#                                 point of images in this package and is NEVER
#                                 written to.
#   .devcontainer/odkc/certs/ca.crt   self-signed CA of the local stack
#
# Writes: only to the target ODK Central (default https://localhost:8383).
#
# Idempotent: forms and submissions that already exist are skipped, so this is
# safe to re-run from postAttachCommand.
#
# ruODK's write helpers are incomplete (project_create() is a stub), so this
# script talks to the REST API through httr directly -- the same package ruODK
# already Imports.

suppressMessages({
  library(httr)
  library(jsonlite)
  library(purrr)
  library(fs)
  library(xml2)
})

say <- function(...) cat(sprintf(...), "\n", sep = "")
say2 <- function(...) cat("  ", sprintf(...), "\n", sep = "")

# --------------------------------------------------------------------------- #
# Configuration
# --------------------------------------------------------------------------- #

fixtures <- path("inst", "extdata", "odkc")
media_dir <- path("vignettes", "media")
ca_file <- path(".devcontainer", "odkc", "certs", "ca.crt")

# Target ODK Central. HTTPS is required: the backend refuses HTTP Basic auth
# over plain HTTP (getodk/central-backend lib/http/preprocessors.js -> httpsOnly).
#
# NOTE this is deliberately NOT ODKC_TEST_URL. That variable points at the
# shared ruodk.getodk.cloud for data-raw/dump_odkc_fixtures.R and for the live
# test suite; reusing it here would aim a WRITE operation at that server.
base_url <- sub("/+$", "", Sys.getenv("ODKC_SEED_URL", "https://localhost:8383"))

# Fail closed: seeding writes projects, forms and submissions. Only a loopback
# target is allowed unless the operator explicitly opts in.
host <- sub("^https?://([^/:]+).*$", "\\1", base_url)
if (!host %in% c("localhost", "127.0.0.1", "::1") &&
    !identical(Sys.getenv("ODKC_SEED_ALLOW_REMOTE"), "1")) {
  stop(
    "Refusing to seed non-loopback target '", base_url, "' (host '", host, "').\n",
    "This script writes projects, forms and submissions.\n",
    "Set ODKC_SEED_ALLOW_REMOTE=1 if you really mean it."
  )
}

# Local admin to create. Deliberately NOT the ruodk.getodk.cloud credentials:
# these are worthless throwaway credentials for a loopback-only container, so
# they are safe to commit (cf. ckanr's ckan_admin/test1234). Phase 3/4 point
# ODKC_TEST_UN / ODKC_TEST_PW at these when targeting the local stack.
seed_un <- Sys.getenv("ODKC_SEED_UN", "ruodk@example.com")
seed_pw <- Sys.getenv("ODKC_SEED_PW", "ruodk-local-password")

# docker compose invocation used to reach the container CLI. The CLI is the
# only way to create the first admin: POST /v1/users needs user.create, and an
# empty server grants that to nobody.
compose <- Sys.getenv(
  "ODKC_COMPOSE",
  "docker compose --env-file .devcontainer/.env -f .devcontainer/docker-compose.yml"
)

for (p in c(fixtures, media_dir)) {
  if (!dir_exists(p)) stop("missing required directory: ", p)
}
for (p in c(path(fixtures, "manifest.json"),
            path(fixtures, "attachments-map.json"),
            ca_file)) {
  if (!file_exists(p)) {
    if (p == ca_file) {
      stop(
        "Local TLS CA not found at ", ca_file, ".\n",
        "Start the stack first (the `certs` service mints it):\n",
        "  docker compose --env-file .devcontainer/.env ",
        "-f .devcontainer/docker-compose.yml up -d --wait"
      )
    }
    stop("missing required file: ", p)
  }
}

manifest <- fromJSON(path(fixtures, "manifest.json"), simplifyVector = FALSE)
att_map <- fromJSON(path(fixtures, "attachments-map.json"), simplifyVector = FALSE)

say("seeding %s", base_url)
say2("fixtures : %s", fixtures)
say2("images   : %s  (read-only)", media_dir)
say2("admin    : %s", seed_un)
say2("forms    : %d", sum(map_int(manifest$projects, ~ length(.x$forms))))

# Trust the local CA. Certificate verification stays ON -- we point libcurl at
# our CA, we do not disable it. Scoped to this process; the seed only talks to
# the local stack. (Setting CURL_CA_BUNDLE instead would REPLACE the system CA
# bundle and break every other https request from R.)
set_config(config(cainfo = ca_file))

# --------------------------------------------------------------------------- #
# HTTP helpers
# --------------------------------------------------------------------------- #

req <- function(method, path, body = NULL, encode = "raw", content_type = NULL) {
  url <- paste0(base_url, path)
  auth <- authenticate(seed_un, seed_pw)
  if (is.null(body)) {
    VERB(method, url, auth)
  } else if (identical(encode, "json")) {
    VERB(method, url, auth, body = body, encode = "json")
  } else if (identical(encode, "multipart")) {
    VERB(method, url, auth, body = body, encode = "multipart")
  } else {
    # Raw body (form XML, or an attachment's bytes).
    VERB(
      method, url, auth,
      add_headers("Content-Type" = content_type %||% "application/xml"),
      body = body
    )
  }
}

`%||%` <- function(a, b) if (is.null(a)) b else a

# Non-throwing existence probe: TRUE when the resource is there.
exists_at <- function(path) {
  r <- tryCatch(req("GET", path), error = function(e) NULL)
  !is.null(r) && status_code(r) < 300
}

urlenc <- function(x) URLencode(x, reserved = TRUE)

# --------------------------------------------------------------------------- #
# 1. First admin
# --------------------------------------------------------------------------- #

say("\n== 1. admin user ==")
authed <- tryCatch(
  status_code(req("GET", "/v1/projects")) < 300,
  error = function(e) FALSE
)
if (authed) {
  say2("already authenticated as %s (skipping user-create)", seed_un)
} else {
  say2("creating %s via `cli.js` in the service container..", seed_un)
  # `compose` is a full command line ("docker compose --env-file ..."), so
  # split it and pass element 1 as the executable. (Handing the whole string to
  # system2() as args of "docker" would produce "docker docker compose ...".)
  compose_args <- strsplit(trimws(compose), "\\s+")[[1]]
  create <- suppressWarnings(system2(
    compose_args[[1]],
    c(compose_args[-1], "exec", "-T", "service",
      "node", "lib/bin/cli.js", "-u", seed_un, "user-create"),
    stdout = TRUE, stderr = TRUE,
    input = seed_pw
  ))
  say2("user-create -> %s", paste(create, collapse = " | "))
  promote <- suppressWarnings(system2(
    compose_args[[1]],
    c(compose_args[-1], "exec", "-T", "service",
      "node", "lib/bin/cli.js", "-u", seed_un, "user-promote"),
    stdout = TRUE, stderr = TRUE
  ))
  say2("user-promote -> %s", paste(promote, collapse = " | "))
}

authed <- tryCatch(
  status_code(req("GET", "/v1/projects")) < 300,
  error = function(e) FALSE
)
if (!authed) stop("could not authenticate as ", seed_un, " after user-create")
say2("authenticated as %s", seed_un)

# --------------------------------------------------------------------------- #
# 2. Projects
# --------------------------------------------------------------------------- #

say("\n== 2. projects ==")
want_pids <- names(manifest$projects)
for (p in want_pids) {
  meta <- manifest$projects[[p]]
  if (exists_at(paste0("/v1/projects/", p))) {
    say2("pid %s exists (%s)", p, meta$name)
  } else {
    r <- req("POST", "/v1/projects",
             body = list(name = meta$name), encode = "json")
    say2("pid %s created '%s' (HTTP %d)", p, meta$name, status_code(r))
  }
}

# --------------------------------------------------------------------------- #
# 3. Forms. XML only -- the dumped XML is the compiled form, so POST /forms
#    takes it directly and pyxform is never needed.
#      ?publish=true  -> published (published_at set)
#      no publish     -> stays a draft (published_at NA). That is what
#                        Locations_draft is on the live server, and
#                        test-form_list.R requires at least one such form.
# --------------------------------------------------------------------------- #

say("\n== 3. forms ==")
for (p in want_pids) {
  forms <- manifest$projects[[p]]$forms
  say2("pid %s: %d form(s)", p, length(forms))
  for (fid in names(forms)) {
    meta <- forms[[fid]]
    xml_path <- path(fixtures, "forms", p, paste0(fid, ".xml"))
    if (!file_exists(xml_path)) stop("missing form XML: ", xml_path)

    if (exists_at(paste0("/v1/projects/", p, "/forms/", urlenc(fid)))) {
      say2("  %-32s exists (skipped)", fid)
      next
    }

    xml_body <- paste(readLines(xml_path, warn = FALSE), collapse = "\n")
    publish <- !isTRUE(meta$is_draft)
    path_q <- paste0(
      "/v1/projects/", p, "/forms", if (publish) "?publish=true" else ""
    )
    r <- tryCatch(req("POST", path_q, body = xml_body), error = function(e) e)
    if (inherits(r, "error")) {
      say2("  %-32s ERROR %s", fid, conditionMessage(r))
    } else {
      say2("  %-32s %s (HTTP %d)", fid,
           if (publish) "published" else "draft   ", status_code(r))
      if (status_code(r) >= 300) {
        say2("      %s", substr(content(r, "text", encoding = "UTF-8"), 1, 200))
      }
    }
  }
}

# --------------------------------------------------------------------------- #
# 4. Submissions + attachments.
#
#    TWO PHASES, on purpose.
#
#    Phase 4a posts only xml_submission_file (multipart with a single part).
#    Sending attachments in the SAME multipart request fails inside ODK
#    Central with a Postgres 22021 "invalid byte sequence for encoding UTF8"
#    on the first JPEG byte (getodk/central, reproducible with a 4-byte file).
#    XML-only uploads work fine.
#
#    Phase 4b fills the bytes in through the documented per-attachment upsert,
#    which takes a raw request body and needs no multipart at all:
#      POST /v1/projects/{pid}/forms/{fid}/submissions/{iid}/attachments/{name}
#    Posting the XML pre-creates the attachment rows with exists=false (i.e.
#    blobId NULL), which is exactly what that route expects to fill in.
#
#    Each submission's <data version="..."> is also aligned to the version of
#    the form we published: several live forms were re-published as "[upgrade]"
#    variants, so their older submissions carry a version Central would reject
#    with 404.6 "the form version specified in this submission does not exist".
# --------------------------------------------------------------------------- #

say("\n== 4. submissions + attachments ==")

form_version_of <- function(pid, fid) {
  x <- read_xml(path(fixtures, "forms", pid, paste0(fid, ".xml")))
  d <- xml_find_first(x, "//.//*[local-name()='data']")
  v <- xml_attr(d, "version")
  if (is.na(v)) "" else v
}

# Rewrite <data version> and, where safe, <instanceID> so the POSTed body is
# addressed by the same id submission_list() reports (the manifest key).
#
# Two reasons:
#  * version: several live forms were re-published as "[upgrade]" variants, so
#    their older submissions carry a version Central rejects with 404.6
#    "the form version specified in this submission does not exist".
#  * instanceID: for 2 of 19 submissions the source server's
#    GET /submissions/{iid}.xml returns a body whose <instanceID> is NOT the
#    iid that was requested (submission_list() and the body disagree). Central
#    stores the BODY id, so the seed's existence probe and later PATCH/upload
#    calls would key off the wrong id.
#
# instanceID is left alone for encrypted submissions: getodk/central-backend
# lib/model/frames/submission.js warns that "the decryption protocol relies on
# the instanceId as a piece of critical decryption input".
align_submission <- function(xml_path, want_version, want_iid) {
  doc <- read_xml(xml_path)
  root <- xml_find_first(doc, "//.//*[local-name()='data']")

  changed <- FALSE
  have_v <- xml_attr(root, "version")
  have_v <- if (is.na(have_v)) "" else have_v
  if (!identical(have_v, want_version)) {
    xml_set_attr(root, "version",
                 if (want_version == "") NA_character_ else want_version)
    changed <- TRUE
  }

  enc <- xml_find_first(doc, "//.//*[local-name()='base64EncryptedKey']")
  if (length(enc) == 0 || is.na(enc)) {
    for (node in xml_find_all(doc, "//.//*[local-name()='instanceID']")) {
      if (!identical(xml_text(node), want_iid)) {
        xml_text(node) <- want_iid
        changed <- TRUE
      }
    }
  }

  if (!changed) return(NULL)
  as.character(doc)
}

mime_for <- function(name) {
  switch(tolower(tools::file_ext(name)),
    jpg = "image/jpeg", jpeg = "image/jpeg", png = "image/png",
    "application/octet-stream"
  )
}

attachment_path <- function(name, entry) {
  q <- path(entry$path)
  if (!file_exists(q)) stop("attachment source missing for ", name, ": ", q)
  q
}

n_new <- 0L
n_skip <- 0L
n_fail <- 0L
n_att_new <- 0L
n_att_fail <- 0L

for (p in want_pids) {
  forms <- manifest$projects[[p]]$forms
  for (fid in names(forms)) {
    meta <- forms[[fid]]
    insts <- meta$submission_instances
    if (length(insts) == 0) next
    fver <- form_version_of(p, fid)

    # manifest order is newest-first (it comes from submission_list(), which
    # sorts createdAt DESC). Replay OLDEST FIRST so the relative createdAt
    # stamps Central assigns at ingest keep the same order as the source
    # server. Several assertions are order-sensitive, e.g.
    # test-odata_submission_get.R reads system_status[[1]] of the encrypted
    # form and expects "NotDecrypted" -- which is the newest submission there.
    insts_replayed <- rev(insts)

    for (iid in insts_replayed) {
      detail <- meta$submissions_detail[[iid]]
      probe_path <- paste0(
        "/v1/projects/", p, "/forms/", urlenc(fid),
        "/submissions/", urlenc(iid)
      )

      # ---- phase 4a: the instance XML alone -----------------------------
      if (!exists_at(probe_path)) {
        xml_path <- path(fixtures, "submissions", p, fid, paste0(iid, ".xml"))
        if (!file_exists(xml_path)) {
          n_fail <- n_fail + 1L
          say2("  %-28s %-40s MISSING %s", fid, iid, xml_path)
          next
        }
        al <- align_submission(xml_path, fver, iid)
        tmp <- xml_path
        if (!is.null(al)) {
          tmp <- tempfile(fileext = ".xml")
          writeLines(al, tmp, useBytes = TRUE)
        }
        body_parts <- list(
          xml_submission_file = upload_file(tmp, type = "application/xml")
        )
        r <- tryCatch(
          req("POST", paste0(
            "/v1/projects/", p, "/forms/", urlenc(fid), "/submissions"
          ), body = body_parts, encode = "multipart"),
          error = function(e) e
        )
        if (inherits(r, "error")) {
          n_fail <- n_fail + 1L
          say2("  %-28s %-40s ERROR %s", fid, iid, conditionMessage(r))
          next
        }
        if (status_code(r) >= 300) {
          n_fail <- n_fail + 1L
          say2("  %-28s %-40s XML FAILED HTTP %d: %s", fid, iid, status_code(r),
               substr(content(r, "text", encoding = "UTF-8"), 1, 160))
          next
        }
        n_new <- n_new + 1L
        say2("  %-28s %-40s xml ok%s", fid, iid,
             if (is.null(al)) "" else " (id/version aligned)")
      } else {
        n_skip <- n_skip + 1L
        say2("  %-28s %-40s exists (skipped)", fid, iid)
      }

      # ---- phase 4b: fill in attachment bytes ---------------------------
      atts <- detail$attachments
      if (length(atts) > 0) {
        for (nm in names(atts)) {
          src <- attachment_path(nm, atts[[nm]])
          url <- paste0(
            "/v1/projects/", p, "/forms/", urlenc(fid),
            "/submissions/", urlenc(iid), "/attachments/", urlenc(nm)
          )
          ar <- tryCatch(
            req("POST", url, body = upload_file(src),
                encode = "raw", content_type = mime_for(nm)),
            error = function(e) e
          )
          # attach() does an unconditional upsert, so re-running is fine.
          if (!inherits(ar, "error") && status_code(ar) < 300) {
            n_att_new <- n_att_new + 1L
          } else {
            n_att_fail <- n_att_fail + 1L
            say2("      att %-30s FAILED %s", nm,
                 if (inherits(ar, "error")) conditionMessage(ar) else
                   paste("HTTP", status_code(ar)))
          }
        }
        say2("      -> %d attachment(s) uploaded for %s", length(atts), iid)
      }

      # ---- phase 4c: reviewState ----------------------------------------
      # Not settable at submit time; PATCH afterwards. Leaving every review
      # state NULL makes class(review_state) logical rather than character
      # (test-submission_list.R).
      want_rs <- detail$review_state
      if (!is.null(want_rs)) {
        pr <- tryCatch(
          req("PATCH", probe_path, encode = "json",
              body = list(reviewState = want_rs)),
          error = function(e) e
        )
        if (!inherits(pr, "error") && status_code(pr) < 300) {
          say2("      reviewState=%s", want_rs)
        } else {
          say2("      reviewState=%s FAILED %s", want_rs,
               if (inherits(pr, "error")) conditionMessage(pr) else
                 paste("HTTP", status_code(pr)))
        }
      }
    }
  }
}
say2("submissions  new: %d  already present: %d  failed: %d",
     n_new, n_skip, n_fail)
say2("attachments  uploaded: %d  failed: %d", n_att_new, n_att_fail)

# --------------------------------------------------------------------------- #
# 5. Verify what the test suite actually depends on
# --------------------------------------------------------------------------- #

say("\n== 5. verify ==")

parsed <- function(path) {
  r <- req("GET", path)
  if (status_code(r) >= 300) return(NULL)
  content(r, "parsed", simplifyVector = FALSE)
}

fl1 <- parsed("/v1/projects/1/forms")
fl2 <- parsed("/v1/projects/2/forms")
fids1 <- map_chr(fl1, "xmlFormId")
fids2 <- map_chr(fl2, "xmlFormId")
say2("pid 1 forms: %d   pid 2 forms: %d", length(fids1), length(fids2))

want <- c(
  FID = Sys.getenv("ODKC_TEST_FID", "Flora-Quadrat-04"),
  FID_ZIP = Sys.getenv("ODKC_TEST_FID_ZIP", "Locations"),
  FID_ATT = Sys.getenv("ODKC_TEST_FID_ATT", "Flora-Quadrat-04-att"),
  FID_GAP = Sys.getenv("ODKC_TEST_FID_GAP", "Flora-Quadrat-04-gap"),
  FID_WKT = Sys.getenv("ODKC_TEST_FID_WKT", "Locations")
)

checks <- c(
  "a draft form exists (test-form_list.R)" =
    any(map_lgl(fl1, ~ is.null(.x$publishedAt))),
  "ODKC_TEST_FID present"       = want[["FID"]] %in% fids1,
  "ODKC_TEST_FID_ATT present"   = want[["FID_ATT"]] %in% fids1,
  "ODKC_TEST_FID_GAP present"   = want[["FID_GAP"]] %in% fids1,
  "ODKC_TEST_FID_WKT present"   = want[["FID_WKT"]] %in% fids1,
  "ODKC_TEST_FID_ENC present (pid 2)" =
    Sys.getenv("ODKC_TEST_FID_ENC", "Locations") %in% fids2
)

# test-entity_*.R does entitylist_list()$name[1]; it needs at least one.
ds <- parsed("/v1/projects/1/datasets")
checks <- c(checks, "an entity list exists (test-entity_*.R)" =
              length(ds) > 0)

# test-attachment_get.R downloads location_quadrat_photo and checks the file
# exists, so ODKC_TEST_FID must have at least one attachment.
fid_main <- want[["FID"]]
sl <- parsed(paste0("/v1/projects/1/forms/", urlenc(fid_main), "/submissions"))
n_att <- 0L
if (!is.null(sl)) {
  for (s in sl) {
    a <- parsed(paste0(
      "/v1/projects/1/forms/", urlenc(fid_main),
      "/submissions/", urlenc(s$instanceId), "/attachments"
    ))
    n_att <- n_att + length(a)
  }
}
checks <- c(
  checks,
  "ODKC_TEST_FID has attachments (test-attachment_get.R)" = n_att > 0
)
say2("(attachments on %s: %d)", fid_main, n_att)

for (nm in names(checks)) {
  say2("[%s] %s", if (isTRUE(checks[[nm]])) "OK  " else "FAIL", nm)
}

say("\n=================================================")
if (!all(checks)) {
  say("seed INCOMPLETE: %d check(s) failed", sum(!unname(checks)))
  quit(status = 1)
}

say("seed OK. Point ruODK at the local stack with:")
vals <- c(
  ODKC_TEST_URL = base_url,
  ODKC_TEST_UN = seed_un,
  ODKC_TEST_PW = "<the value of ODKC_SEED_PW>",
  ODKC_TEST_PID = "1",
  ODKC_TEST_PID_ENC = "2",
  ODKC_TEST_PP = "ThePassphrase",
  ODKC_TEST_FID = want[["FID"]],
  ODKC_TEST_FID_ZIP = want[["FID_ZIP"]],
  ODKC_TEST_FID_ATT = want[["FID_ATT"]],
  ODKC_TEST_FID_GAP = want[["FID_GAP"]],
  ODKC_TEST_FID_WKT = want[["FID_WKT"]],
  ODKC_TEST_FID_ENC = Sys.getenv("ODKC_TEST_FID_ENC", "Locations")
)
for (nm in names(vals)) {
  say("  %s=\"%s\"", nm, vals[[nm]])
}
say("  # plus ODKC_TEST_VERSION=<semver of this ODK Central>, and")
say("  # CURL_CA_BUNDLE=<merged system CAs + %s>", ca_file)
