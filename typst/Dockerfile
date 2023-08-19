FROM fj0rd/0x:fonts

RUN set -eux \
  ; mkdir -p /world/typst \
  ; curl -sSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz \
    | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/typst' \
  ;
COPY assets/cn.typ /world/typst
