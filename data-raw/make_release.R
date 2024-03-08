# Package maintainers can use the steps below to prepare a new release.

# -----------------------------------------------------------------------------#
# Implement new features
#
# Starting from a clean code base, create new dev version
usethis::use_version(which = "patch")
# Write code, add tests
# Add new feature to news if user-facing
usethis::edit_file("NEWS.md")

# Package dependencies:
# Make sure that required versions are available on CRAN as binaries for all
# tested = supported OS and R combinations!

# -----------------------------------------------------------------------------#
# Regenerate test data
# -----------------------------------------------------------------------------#
source(here::here("data-raw/make_data.R"))

# -----------------------------------------------------------------------------#
# Build PDF manual
# -----------------------------------------------------------------------------#
# vignettes/manual.Rnw: (gitignore)
# \documentclass{article}
# \usepackage{pdfpages}
# %\VignetteIndexEntry{manual}
# \begin{document}
# \SweaveOpts{concordance=TRUE}
# \includepdf[pages=-, fitpaper=true]{../inst/extdoc/ruODK.pdf}
# \end{document}
fs::dir_ls("inst/extdoc/", glob = "*.pdf") %>% fs::file_delete()
devtools::build_manual(path = "inst/extdoc")
tools::compactPDF(fs::dir_ls("inst/extdoc/"), gs_quality = "ebook")
purrr::map(
  fs::dir_ls("inst/extdoc/", glob = "*.pdf"),
  ~ fs::file_move(., "inst/extdoc/ruODK.pdf")
)

# -----------------------------------------------------------------------------#
# Style, lint, spell check
# -----------------------------------------------------------------------------#
styler::style_pkg()
lintr:::addin_lint_package()
devtools::document(roclets = c("rd", "collate", "namespace", "vignette"))
spelling::spell_check_package()
spelling::spell_check_files("README.Rmd", lang = "en-AU")
spelling::update_wordlist()
codemetar::write_codemeta("../ruODK", write_minimeta = TRUE)
if (fs::file_info("README.md")$modification_time <
  fs::file_info("README.Rmd")$modification_time) {
  rmarkdown::render("README.Rmd", encoding = "UTF-8", clean = TRUE)
  if (fs::file_exists("README.html")) fs::file_delete("README.html")
}
#
# Wipe cached server responses (vcr cassettes)
# If tests are run against outdated vcr cassettes, new server behaviour
# may not be detected
fs::dir_ls(here::here("tests/fixtures/"), glob = "*.yml") %>% fs::file_delete()
# Checks
pkgdown::build_site() # Simulate
goodpractice::goodpractice(quiet = FALSE)
devtools::check(cran = TRUE, remote = TRUE, incoming = TRUE)
chk <- rcmdcheck::rcmdcheck(args = c("--as-cran"))

# Commit and push

# -----------------------------------------------------------------------------#
# Release package
# -----------------------------------------------------------------------------#
# Code and docs tested, working, committed
usethis::use_version("patch")
usethis::edit_file("NEWS.md")
usethis::edit_file("inst/CITATION")

# Tag and push
devtools::document()
v <- packageVersion("ruODK")
system(glue::glue("git tag -a v{v} -m 'v{v}' && git push && git push --tags"))

# Build Docker image - now happens on pushing tags beginning with "v"
# dn <- "dbcawa/ruodk"
# dv <- packageVersion("ruODK")
# gp <- Sys.getenv("GITHUB_PAT")
# message(glue::glue("Building and pushing {dn}:{dv}..."))
# system(glue::glue(
#   "docker build . -t {dn}:latest -t {dn}:{dv} --build-arg GITHUB_PAT={gp}"
#   " && docker push {dn}"
# ))
