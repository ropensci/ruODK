FROM rocker/geospatial:4.0.3
LABEL maintainer=Florian.Mayer@dbca.wa.gov.au
LABEL description="rocker/geospatial:4.0.3 for DBCA"

# Build this image with
# docker build . -t dbcawa/ruodk:latest --build-arg GITHUB_PAT="..."

ARG GITHUB_PAT
ENV GITHUB_PAT=${GITHUB_PAT}

# System dependencies ---------------------------------------------------------#
RUN apt-get update && \
    apt remove -y libvorbis0a && \
    apt-get -y install --no-install-recommends \
    python3-venv python3-dev \
    # DBCA package deps:
    rsync mdbtools cargo libavfilter-dev libfontconfig1-dev libopenblas-dev \
    freetds-common libct4 libsybdb5 freetds-bin freetds-common freetds-dev \
    libct4 libsybdb5 tdsodbc unixodbc && \
    apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# R packages ------------------------------------------------------------------#
RUN install2.r --error \
  caTools \
  bitops \
  ckanr \
  googledrive \
  fuzzyjoin \
  leaflet \
  leaflet.extras \
  leaflet.providers \
  leaftime \
  reactable \
  skimr \
  usethis \
  mapview \
  leafpop \
  leafem \
  lattice \
  sf

RUN R -e "remotes::install_github('ropensci/ruODK@main', \
          dependencies = TRUE, ask=FALSE, update=TRUE)"
