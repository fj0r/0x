FROM fj0rd/0x:pyflink-dev

RUN set -eux \
  ; mill_version=$(curl -sSL https://api.github.com/repos/lihaoyi/mill/releases/latest | jq -r '.tag_name') \
  ; curl -sSL https://github.com/lihaoyi/mill/releases/download/${mill_version}/${mill_version} -o /usr/local/bin/mill \
  ; chmod +x /usr/local/bin/mill \
  ;

ARG metals_repo=scalameta/metals

RUN set -eux \
  ; curl -sSL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > /usr/local/bin/cs \
  ; chmod +x /usr/local/bin/cs \
  ; cs install scala:2.12 \
  ; cs install metals \
  ;
