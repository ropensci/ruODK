# Package maintainers can use the steps below to prepare a new release.

# -----------------------------------------------------------------------------#
# Implement new features
#
# Starting from a clean code base, create new dev version
usethis::use_version(which = "dev")
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
# vignettes/manual.Rnw:
# \documentclass{article}
# \usepackage{pdfpages}
# %\VignetteIndexEntry{manual}
# \begin{document}
# \SweaveOpts{concordance=TRUE}
# \includepdf[pages=-, fitpaper=true]{../inst/extdoc/ruODK.pdf}
# \end{document}
fs::file_delete("inst/extdoc/*.pdf")
devtools::build_manual(path = "inst/extdoc") # rm > pdf
fs::file_move(fs::dir_ls("inst/extdoc/"), "inst/extdoc/ruODK.pdf") # rename pdf
tools::compactPDF("inst/extdoc/ruODK.pdf", gs_quality = "ebook") # compress pdf
usethis::edit_file("vignettes/manual.Rnw") # hit "Compile PDF"

# -----------------------------------------------------------------------------#
# Style, lint, spellcheck
# -----------------------------------------------------------------------------#
styler::style_pkg()
lintr:::addin_lint_package()
devtools::document(roclets = c("rd", "collate", "namespace"))
spelling::spell_check_package()
spelling::spell_check_files("README.Rmd", lang = "en_AU")
spelling::update_wordlist()
codemetar::write_codemeta("ruODK")
if (fs::file_info("README.md")$modification_time <
  fs::file_info("README.Rmd")$modification_time) {
  rmarkdown::render("README.Rmd", encoding = "UTF-8", clean = TRUE)
  if (fs::file_exists("README.html")) fs::file_delete("README.html")
}
#
# Checks
goodpractice::goodpractice(quiet = FALSE)
devtools::check(cran = TRUE, remote = TRUE, incoming = TRUE)
chk <- rcmdcheck::rcmdcheck(args = c("--as-cran"))

# Commit and push

# -----------------------------------------------------------------------------#
# Release package
# -----------------------------------------------------------------------------#
# Code and docs tested, working, committed
usethis::use_version()
usethis::edit_file("NEWS.md")
usethis::edit_file("inst/CITATION")

# Git commit, then tag and push
v <- packageVersion("ruODK")
system(glue::glue("git tag -a {v} -m '{v}'"))
system(glue::glue("git push origin {v}"))

# Build Docker image
dn <- "dbcawa/ruodk"
dv <- packageVersion("ruODK")
gp <- Sys.getenv("GITHUB_PAT")
message(glue::glue("Building and pushing {dn}:{dv}..."))
system(glue::glue(
  "docker build . -t {dn} -t {dn}:{dv} ",
  "--build-arg GITHUB_PAT={gp} && docker push {dn}"
))
