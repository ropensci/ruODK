options(repos = c(ropensci = 'https://ropensci.r-universe.dev',
                  MRAN = 'https://mran.microsoft.com/snapshot/2020-07-16',
                  CRAN = 'https://cloud.r-project.org'))

# install.packages("remotes")
# install.packages("rmarkdown")
install.packages("mapview")
install.packages("gt")
install.packages("reactable")

install.packages("leaflet")
install.packages("leaflet.extras")
install.packages("leaflet.providers")
install.packages("leaftime")
install.packages("caTools")
install.packages("bitops")
install.packages("ckanr")
install.packages("googledrive")

install.packages('ruODK')
# remotes::install_github(
#   'ropensci/ruODK@main',
#   force = TRUE,
#   ask=FALSE,
#   upgrade='never',
#   dependencies = c('Depends', 'Imports', 'Suggests')
# )