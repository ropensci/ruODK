FROM ghcr.io/rocker-org/devcontainer/r-ver:4.6

# non interactive frontend for locales
ENV DEBIAN_FRONTEND=noninteractive

# installing texlive and utils
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    libudunits2-dev libxtst6 libxt6 libmagick++-dev \
    libxml2-dev libjq-dev libudunits2-dev libgdal-dev libgeos-dev libproj-dev \
    libicu-dev libv8-dev libjq-dev libprotobuf-dev protobuf-compiler libgit2-dev \
    rsync mdbtools cargo libavfilter-dev libfontconfig1-dev libopenblas-dev \
    freetds-common libct4 libsybdb5 freetds-bin freetds-dev libsybdb5 tdsodbc \
    unixodbc make git procps locales curl && \
    rm -rf /var/lib/apt/lists/*

# generating locales
RUN sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_GB.UTF-8
ENV LANGUAGE=en_GB.UTF-8 LANG=en_GB.UTF-8 LC_ALL=en_GB.UTF-8

# installing cpanm & missing latexindent dependencies
RUN curl -L http://cpanmin.us | perl - --self-upgrade && \
    cpanm Log::Dispatch::File YAML::Tiny File::HomeDir

# opencode CLI baked in for the rstudio dev user (postAttachCommand.sh keeps
# a fallback install for images built before this line existed). HOME is
# exported first so both sides of the pipe see it (a VAR=x prefix would
# reach only curl, installing to /root instead); the binary lands in the
# user's ~/.opencode/bin owned by them (keeps opencode autoupdate working);
# --no-modify-path because postAttach owns PATH wiring.
RUN export HOME=/home/rstudio && curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path && \
    chown -R rstudio /home/rstudio/.opencode
