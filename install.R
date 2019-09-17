# This file contains the install steps for binder (https://mybinder.org/)
# https://mybinder.readthedocs.io/en/latest/using.html#preparing-a-repository-for-binder

# Package management
install.packages("remotes")
install.packages("usethis")
remotes::install_github("dbca-wa/ruODK", dependencies = TRUE)

# Data wrangling
install.packages("janitor")

# Data visualisation
install.packages("skimr")
install.packages("DT")
install.packages("ggplot2")
install.packages("leaflet")
install.packages("listviewer")

# RMarkdown
install.packages("caTools")
install.packages("bitops")
install.packages("rmarkdown")
install.packages("knitr")

# Data dissemination
install.packages("ckanr")
install.packages("googledrive")