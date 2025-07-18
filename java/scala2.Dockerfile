FROM fj0rd/java:8

ENV SCALA_HOME=/opt/scala
ENV PATH=${SCALA_HOME}/bin:$PATH

RUN set -eux \
  ; mkdir -p /usr/share/man/man1 \
  ; mkdir -p ${SCALA_HOME} \
  ; curl --retry 3 -fsSL $(curl --retry 3 -fsSL https://scala-lang.org/download/|pup '[id="#link-main-unixsys"] attr{href}') \
      | tar xzf - -C ${SCALA_HOME} --strip-components=1

ARG github_header="-H 'Accept: application/vnd.github.v3+json'"
ARG github_api=https://api.github.com/repos
ARG mill_repo=lihaoyi/mill

RUN set -eux \
  ; mill_version=$(curl --retry 3 -fsSL $github_api/${mill_repo}/releases $github_header | jq -r '.[0].tag_name') \
  ; curl --retry 3 -fsSL https://github.com/lihaoyi/mill/releases/download/${mill_version}/${mill_version} > /usr/local/bin/mill \
  ; chmod +x /usr/local/bin/mill

ARG metals_repo=scalameta/metals

RUN set -eux \
  ; metals_version=$(curl --retry 3 -fsSL $github_api/${metals_repo}/releases $github_header | jq -r '.[0].tag_name'|cut -c 2-) \
  ; java -Dfile.encoding=UTF-8 -jar \
    /etc/skel/.config/nvim/coc-data/extensions/node_modules/coc-metals/coursier \
    fetch -p --ttl Inf org.scalameta:metals_2.12:${metals_version} \
    -r bintray:scalacenter/releases \
    -r sonatype:public \
    -r sonatype:snapshots -p

