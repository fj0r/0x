FROM fj0rd/java:11

ENV SCALA_HOME=/opt/scala
ENV PATH=${SCALA_HOME}/bin:$PATH

RUN set -eux \
  ; xh -Fo /usr/local/bin/cs https://git.io/coursier-cli-"$(uname | tr LD ld)" \
  ; chmod +x /usr/local/bin/cs \
  ; cs install scala3-compiler scala3-repl

ARG github_header="Accept:application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos
ARG metals_repo=scalameta/metals
ARG mill_repo=lihaoyi/mill

RUN set -eux \
  ; metals_version=$(xh $github_api/${metals_repo}/releases $github_header | jq -r '.[0].tag_name'|cut -c 2-) \
  ; cs bootstrap \
  --java-opt -Xss4m \
  --java-opt -Xms100m \
  org.scalameta:metals_3:${metals_version} \
  -r bintray:scalacenter/releases \
  -r sonatype:snapshots \
  -o /usr/local/bin/metals -f

RUN set -eux \
  ; mill_version=$(xh $github_api/${mill_repo}/releases $github_header  | jq -r '.[0].tag_name') \
  ; xh -F https://github.com/lihaoyi/mill/releases/download/${mill_version}/${mill_version} > /usr/local/bin/mill \
  ; chmod +x /usr/local/bin/mill

