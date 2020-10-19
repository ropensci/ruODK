# Package mainainers can use the steps below to prepare a new release.

# -----------------------------------------------------------------------------#
# Implement new features
#
# Starting from a clean code base, create new dev version
usethis::use_version(which = "dev")

# Write code, add tests

# Package dependencies:
# Make sure that required versions are available on CRAN as binaries for all
# tested = supported OS and R combinations!

# regenerate test data
source(here::here("data-raw/make_data.R"))

# Tests
devtools::test()
#
# Docs
styler::style_pkg()
lintr:::addin_lint_package()
devtools::document(roclets = c("rd", "collate", "namespace"))
spelling::spell_check_package()
spelling::spell_check_files("README.Rmd", lang = "en_AU") # TODO update wordlist
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
#
# Add new feature to news if user-facing
usethis::edit_file("NEWS.md")

# Commit and push

# -----------------------------------------------------------------------------#
# Release package
#
# Code and docs tested, working, committed
usethis::use_version()
usethis::edit_file("NEWS.md")
usethis::edit_file("inst/CITATION")
#
# Build site
# pkgdown::build_site() # GHA builds pkgdown site
#
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

# -----------------------------------------------------------------------------#
# Backyard
#
# Build PDF manual: not required!
# Contents of vignettes/manual.Rnw:
# \documentclass{article}
# \usepackage{pdfpages}
# %\VignetteIndexEntry{Manual}
# \begin{document}
# \SweaveOpts{concordance=TRUE}
# \includepdf[pages=-, fitpaper=true]{../inst/extdoc/ruODK.pdf}
# \end{document}
#
# fs::file_delete("inst/extdoc/ruODK.pdf")
# devtools::build_manual(path = "inst/extdoc") # rm > pdf
# fs::file_move(fs::dir_ls("inst/extdoc/"), "inst/extdoc/ruODK.pdf") # rename pdf
# tools::compactPDF("inst/extdoc/ruODK_0.9.1.pdf", gs_quality = "ebook") # compress pdf
# usethis::edit_file("vignettes/manual.Rnw") # hit "Compile PDF"
#
# -----------------------------------------------------------------------------#
# Build site - built by TravisCI
# pkgdown::build_site()
# if https://github.com/r-lib/pkgdown/issues/1157 happens:
# httr::set_config(httr::config(ssl_verifypeer = 0L))
# pkgdown::build_site(pkg = ".", new_process = FALSE)
# * `usethis::use_pkgdown_travis()`
# * creates a branch gh-pages
# * gitignores docs/
#   * instructs to paste into tavis.yml the following block
#     (note RStudio auto-indent will mess up the indent -
#     `deploy` must be top level)
# ```
# before_cache: Rscript -e 'remotes::install_cran("pkgdown")'
# deploy:
#   provider: script
#   script: Rscript -e 'pkgdown::deploy_site_github()'
#   cleanup: false
#   skip_cleanup: true
# ```
# * `travis::browse_travis_token(endpoint = '.org')` opens
#   <https://travis-ci.org/account/preferences> to view Travis API key
# * `usethis::edit_r_environ()` to open ~/.Renviron >
#   add `R_TRAVIS_ORG = "xxx"`, restart session
# * `travis::use_travis_deploy(endpoint = ".org")`
#   creates a deploy key on <https://github.com/https://github.com/ropensci/ruODK/issues/66/ruODK> > Settings >
#   Deploy keys using the authentication from the Travis CI API token.
#   Push a change or trigger a travis build.
# * <https://github.com/https://github.com/ropensci/ruODK/issues/66/ruODK> > Settings > GitHub pages:
#   build from gh-pages branch.
