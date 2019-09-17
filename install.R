# This file contains the install steps for binder (https://mybinder.org/)
# https://mybinder.readthedocs.io/en/latest/using.html#preparing-a-repository-for-binder
remotes::install_github("dbca-wa/ruODK", dependencies = TRUE)
install.packages("rmarkdown")