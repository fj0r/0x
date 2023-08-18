FROM fj0rd/io:rs as build

RUN cargo install mdbook mdbook-epub mdbook-pdf \
 && strip /opt/cargo/bin/mdbook-epub \
 && strip /opt/cargo/bin/mdbook-pdf \
 && strip /opt/cargo/bin/mdbook

FROM fj0rd/io

COPY --from=build /opt/cargo/bin/mdbook /opt/cargo/bin/mdbook-epub /usr/local/bin

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        #python3 python3-pip python3-setuptools ipython3 \
        libnss3 libnspr4 libgbm1 libx11-xcb-dev libdbus-glib-1-2 \
        libgles2 gstreamer1.0-libav \
        libglib2.0-0 libatk1.0-0 libatk-bridge2.0-0 libxcb1 \
        libcups2 libdbus-1-3 libxkbcommon0 libgtk-3-0 libxt6 \
        libpango-1.0-0 libcairo2 libgdk-pixbuf2.0-0 libasound2 libatspi2.0-0 \
        fonts-arphic-ukai fonts-arphic-uming \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ; pip3 install --default-timeout=100 --no-cache-dir \
        Requests furl html5lib \
        playwright \
  ; python3 -m playwright install \
  \
  ; pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

ENV DEBUG=pw:api
# python3 -m playwright codegen

RUN set -eux \
  ; mkdir -p /world/typst \
  ; curl -sSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz \
    | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/typst' \
  ;
COPY assets/cn.typ /world/typst
