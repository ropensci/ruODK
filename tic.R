# installs dependencies, runs R CMD check, runs covr::codecov()
do_package_checks(
  # error_on="error",
  args = c(
    # "--no-manual",
    "--as-cran",
    # "--no-vignettes",
    # "--no-build-vignettes",
    "--no-multiarch"
  )
)

if (ci_on_ghactions() && ci_has_env("BUILD_PKGDOWN")) {
  # creates pkgdown site and pushes to gh-pages branch
  # only for the runner with the "BUILD_PKGDOWN" env var set
  do_pkgdown()
}
