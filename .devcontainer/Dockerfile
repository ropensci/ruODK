# Pinned by digest for reproducible, tamper-evident builds (tag documents the
# intent: R 4.6). Same pin as ropensci/ckanr; verified against a local pull.
FROM ghcr.io/rocker-org/devcontainer/r-ver:4.6@sha256:1660ee0beba698f16c84b9bdeba7014c09c9e9588ee307174f6b9f53a6276c4f

# non interactive frontend for locales
ENV DEBIAN_FRONTEND=noninteractive

# installing texlive and utils
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    libudunits2-dev libxtst6 libxt6 libmagick++-dev \
    libxml2-dev libjq-dev libgdal-dev libgeos-dev libproj-dev \
    libicu-dev libv8-dev libprotobuf-dev protobuf-compiler libgit2-dev \
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
RUN curl -L https://cpanmin.us | perl - --self-upgrade && \
    cpanm Log::Dispatch::File YAML::Tiny File::HomeDir

# Install OpenCode (https://opencode.ai) system-wide so it is on PATH for all
# users and shells (bash, zsh, non-interactive) without PATH wiring.
# Pattern mirrors ropensci/ckanr: the installer always lands in
# $HOME/.opencode/bin (no prefix option), so move the binary to
# /usr/local/bin and drop the per-user dir. Build runs as root, hence
# /root/.opencode. Unpinned on purpose: the fork's release tags (latest
# v1.19.0) do not match its binary version strings (running v2.0.28, and no
# such tag exists), so a --version pin cannot be verified here; the trailing
# --version call fails the build if the install breaks. Hardened curl flags
# (--proto/--tlsv1.2) as in ckanr.
RUN curl --proto '=https' --tlsv1.2 -fsSL https://opencode.ai/install | \
    bash -s -- --no-modify-path && \
    mv /root/.opencode/bin/opencode /usr/local/bin/opencode && \
    rmdir -p /root/.opencode/bin 2>/dev/null || true; \
    opencode --version

# Posit air R formatter (https://posit-dev.github.io/air/cli.html), pinned so
# image builds stay reproducible. Keep in sync with the "air >= 0.11" note
# in AGENTS.md.
# AIR_INSTALL_DIR points at /usr/local/bin because this cargo-dist installer
# lays binaries out flat (no `bin/` subdir is created); AIR_NO_MODIFY_PATH
# skips shell-rc edits, which are meaningless at build time.
RUN export AIR_INSTALL_DIR=/usr/local/bin AIR_NO_MODIFY_PATH=1 && \
    curl -LsSf https://github.com/posit-dev/air/releases/download/0.11.0/air-installer.sh | sh && \
    air --version
