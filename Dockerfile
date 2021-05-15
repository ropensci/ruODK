FROM rocker/geospatial:4.0.5
LABEL maintainer=Florian.Mayer@dbca.wa.gov.au
LABEL description="rocker/geospatial:4.0.5 for DBCA"

# Build this image with
# docker build . -t dbcawa/ruodk:latest --build-arg GITHUB_PAT="..."

ARG GITHUB_PAT
ENV GITHUB_PAT=${GITHUB_PAT}

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
RUN install2.r --error \
  proj4 \
  caTools \
  bitops \
  ckanr \
  googledrive \
  fuzzyjoin \
  leaflet \
  leaflet.extras \
  leaflet.providers \
  leaftime \
  listviewer \
  reactable \
  skimr \
  stringi \
  usethis \
  mapview \
  leafpop \
  leafem \
  lattice \
  sf

RUN R -e "remotes::install_github('ropensci/ruODK@main', \
          dependencies = TRUE, ask=FALSE, update=TRUE)"
