ARG PG_VERSION_MAJOR=16
FROM postgres:${PG_VERSION_MAJOR}

ARG RUST_CHANNEL=stable
ENV PGRX_VERSION=0.11.2

ENV PATH="/root/.cargo/bin:$PATH"
ENV PGX_HOME=/usr/lib/postgresql/${PG_MAJOR}
RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    build-essential \
    gnupg \
    curl \
    jq \
    git \
    make \
    gcc \
    clang \
    pkg-config \
    postgresql-server-dev-${PG_MAJOR} \
    tree \
  \
  ; rg_ver=$(curl --retry 3 -sSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name') \
  ; rg_url="https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${rg_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/rg' \
  \
  ; fd_ver=$(curl --retry 3 -sSL https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name') \
  ; fd_url="https://github.com/sharkdp/fd/releases/latest/download/fd-${fd_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${fd_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/fd' \
  \
  ; dust_ver=$(curl --retry 3 -sSL https://api.github.com/repos/bootandy/dust/releases/latest | jq -r '.tag_name') \
  ; dust_url="https://github.com/bootandy/dust/releases/latest/download/dust-${dust_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${dust_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/dust' \
  \
  ; curl --retry 3 -sSL https://sh.rustup.rs \
    | sh -s -- --default-toolchain ${RUST_CHANNEL} -y \
  ; rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; cargo install cargo-get \
  ; cargo install --locked cargo-pgrx --version "${PGRX_VERSION}" \
  ; cargo pgrx init "--pg${PG_MAJOR}=/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config"
