FROM rocker/binder:4.1.3 as base
LABEL maintainer=Florian.Mayer@dbca.wa.gov.au
LABEL description="rocker/binder:4.1.3 with ruODK"
# Build this image with
# docker build . -t dbcawa/ruodk:latest --build-arg GITHUB_PAT="..."
# Run this image as Jupyter Notebook with
# docker run -p 8888:8888 dbcawa/ruodk:latest
# Open URL, then select New > Rstudio

# Build args ------------------------------------------------------------------#
ARG NB_USER
ARG NB_UID
ARG GITHUB_PAT
ENV GITHUB_PAT=$GITHUB_PAT

# Home directory --------------------------------------------------------------#
USER root
COPY inst/binder ${HOME}
RUN chown -R ${NB_USER} ${HOME}

# System dependencies ---------------------------------------------------------#
RUN apt-get update --fix-missing && apt remove -y libvorbis0a && \
    xargs -a apt.txt apt-get -y install --no-install-recommends && \
    apt-get purge && apt-get clean && rm -rf /var/lib/apt/lists/*

# R packages ------------------------------------------------------------------#
FROM base as r_libs
USER ${NB_USER}
RUN if [ -f install.R ]; then R --quiet -f install.R; fi
