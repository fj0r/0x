FROM fj0rd/io:base as scala
ENV SCALA_HOME=/opt/scala
ENV PATH=${SCALA_HOME}/bin:$PATH
RUN set -eux \
  ; pup_ver=$(curl -sSL https://api.github.com/repos/ericchiang/pup/releases/latest | jq -r '.tag_name') \
  ; pup_url=https://github.com/ericchiang/pup/releases/download/${pup_ver}/pup_${pup_ver}_linux_amd64.zip \
  ; curl -sSL ${pup_url} -o pup.zip && unzip pup.zip && rm -f pup.zip && chmod +x pup && mv pup /usr/local/bin \
  \
  ; mkdir -p /usr/share/man/man1 \
  ; mkdir -p ${SCALA_HOME} \
  ; curl -sSL $(curl -sSL https://scala-lang.org/download/|pup '[id="#link-main-unixsys"] attr{href}') \
      | tar xzf - -C ${SCALA_HOME} --strip-components=1 \
  ;


FROM fj0rd/0x:pyflink-dev

ENV SCALA_HOME=/opt/scala
ENV PATH=${SCALA_HOME}/bin:$PATH

COPY --from=scala /opt/scala /opt/scala

RUN set -eux \
  ; mill_version=$(curl -sSL https://api.github.com/repos/lihaoyi/mill/releases/latest | jq -r '.tag_name') \
  ; curl -sSL https://github.com/lihaoyi/mill/releases/download/${mill_version}/${mill_version} -o /usr/local/bin/mill \
  ; chmod +x /usr/local/bin/mill \
  ;

ARG metals_repo=scalameta/metals

RUN set -eux \
  ; curl -sSL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > /usr/local/bin/cs \
  ; chmod +x /usr/local/bin/cs \
  ; cs install metals \
  ;

