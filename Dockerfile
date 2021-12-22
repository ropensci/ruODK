FROM rocker/geospatial:4.1.1 as builder_base
LABEL maintainer=Florian.Mayer@dbca.wa.gov.au
LABEL description="rocker/geospatial:4.1.1 with ruODK and extras for DBCA"
# Build this image with
# docker build . -t dbcawa/ruodk:latest --build-arg GITHUB_PAT="..."

# System dependencies ---------------------------------------------------------#
RUN apt-get update && \
    apt remove -y libvorbis0a && \
    apt-get -y install --no-install-recommends \
    python3-venv python3-dev \
    # ruODK deps:
    libxml2-dev libjq-dev libudunits2-dev libgdal-dev \
    libgeos-dev libproj-dev libicu-dev libv8-dev libjq-dev libprotobuf-dev \
    protobuf-compiler libgit2-dev \
    # DBCA deps:
    rsync mdbtools cargo libavfilter-dev libfontconfig1-dev libopenblas-dev \
    freetds-common libct4 libsybdb5 freetds-bin freetds-common freetds-dev \
    libct4 libsybdb5 tdsodbc unixodbc
    #&& apt-get purge && #apt-get clean && rm -rf /var/lib/apt/lists/*

# R packages ------------------------------------------------------------------#
FROM builder_base as r_libs
ARG GITHUB_PAT
ENV GITHUB_PAT=$GITHUB_PAT
RUN install2.r --error \
  caTools \
  bitops \
  ckanr \
  googledrive \
  fuzzyjoin \
  leaflet \
  leaflet.extras \
  leaflet.providers \
  leaftime

FROM r_libs
RUN R -e "remotes::install_github('ropensci/ruODK@main', force = TRUE, ask=FALSE, upgrade='always', dependencies = c('Depends', 'Imports', 'Suggests'))"
