# Package mainainers can use the steps below to prepare a new release.

# -----------------------------------------------------------------------------#
# Implement new features
#
# Starting from a clean code base, create new dev version
usethis::use_version()

# Write code, add tests

# Tests
devtools::test()
#
# Docs
styler::style_pkg()
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
#
# Build site
pkgdown::build_site()
#
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
pkgdown::build_site()
#
# Git commit, then tag and push
v <- packageVersion("ruODK")
system(glue::glue("git tag -a {v} -m '{v}'"))
system(glue::glue("git push origin {v}"))

# -----------------------------------------------------------------------------#
# If attachments in vignettes change
#
# Vignettes are big
# the repo is small
# so what shall we do
# let's mogrify all
system("find vignettes/attachments/media -type f -exec mogrify -resize 200x150 {} \\;")
vignette_tempfiles <- here::here("vignettes", "attachments", "media")
docs_media <- here::here("docs", "articles", "attachments", "media")
fs::dir_copy(vignette_tempfiles, docs_media, overwrite = TRUE)




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
# tools::compactPDF("inst/extdoc/ruODK.pdf", gs_quality = "ebook") # compress pdf
# usethis::edit_file("vignettes/manual.Rnw") # hit "Compile PDF"
#