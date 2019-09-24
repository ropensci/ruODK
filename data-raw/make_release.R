# Package mainainers can use the steps below to prepare a new release.

# -----------------------------------------------------------------------------#
# Prepare package: run steps, fix errors, start over until all steps pass
#
# Tests
devtools::test()
#
# Docs
styler::style_pkg()
devtools::document(roclets = c("rd", "collate", "namespace"))
spelling::spell_check_package()
spelling::spell_check_files("README.Rmd", lang = "en_AU") # How to update word list from that?
spelling::update_wordlist()
codemetar::write_codemeta("ruODK")
usethis::edit_file("inst/CITATION")
if (fs::file_info("README.md")$modification_time <
  fs::file_info("README.Rmd")$modification_time) {
  rmarkdown::render("README.Rmd", encoding = "UTF-8", clean = TRUE)
  if (fs::file_exists("README.html")) fs::file_delete("README.html")
}
#
# Checks
goodpractice::goodpractice(quiet = FALSE)
devtools::check(cran = TRUE, remote = TRUE, incoming = TRUE)

# -----------------------------------------------------------------------------#
# Release package
#
usethis::use_version("minor") # or hand-edit DESC, CIT
usethis::edit_file("NEWS.md")
devtools::build_manual(path = "man")
pkgdown::build_site()

# Vignettes are big
# the repo is small
# so what shall we do
# let's mogrify all
system("find vignettes/attachments/media -type f -exec mogrify -resize 200x150 {} \\;")
vignette_tempfiles <- here::here("vignettes", "attachments", "media")
docs_media <- here::here("docs", "articles", "attachments", "media")
fs::dir_copy(vignette_tempfiles, docs_media, overwrite = TRUE)

# Git commit, tag and push
