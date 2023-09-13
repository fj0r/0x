FROM fj0rd/io:rs as build

RUN cargo install mdbook mdbook-epub mdbook-pdf \
 && strip /opt/cargo/bin/mdbook-epub \
 && strip /opt/cargo/bin/mdbook-pdf \
 && strip /opt/cargo/bin/mdbook

FROM fj0rd/0x:fonts

COPY --from=build \
     /opt/cargo/bin/mdbook \
     /opt/cargo/bin/mdbook-pdf \
     /opt/cargo/bin/mdbook-epub \
     /usr/local/bin/

RUN set -eux \
  ; mkdir -p /world/typst \
  ; curl -sSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz \
    | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/typst' \
  ;
COPY assets/cn.typ /world/typst
