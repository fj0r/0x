FROM ghcr.io/fj0r/io:rust AS build

RUN set -eux \
  ; cargo install mdbook mdbook-pdf mdbook-epub mdbook-typst \
  ; strip /opt/cargo/bin/mdbook-pdf \
  ; strip /opt/cargo/bin/mdbook-epub \
  ; strip /opt/cargo/bin/mdbook-typst \
  ; strip /opt/cargo/bin/mdbook

FROM ghcr.io/fj0r/0x:fonts

COPY --from=build \
     /opt/cargo/bin/mdbook \
     /opt/cargo/bin/mdbook-pdf \
     /opt/cargo/bin/mdbook-epub \
     /opt/cargo/bin/mdbook-typst \
     /usr/local/bin/

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        chromium libx11-xcb-dev \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ; mkdir -p /world/typst \
  ; curl --retry 3 -fsSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz \
    | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/typst' \
  \
  ; curl --retry 3 -fsSLo /usr/local/bin/typst-lsp \
    https://github.com/nvarner/typst-lsp/releases/latest/download/typst-lsp-x86_64-unknown-linux-musl \
  ; chmod +x /usr/local/bin/typst-lsp \
  ;
COPY templates /world
