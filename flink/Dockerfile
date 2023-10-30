# https://github.com/apache/flink-docker
#FROM fj0rd/io:latest
#ARG PIP_FLAGS="--break-system-packages"
FROM python:3.10-bookworm
ARG PIP_FLAGS=""

ENV XDG_CONFIG_HOME=/etc \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai
ENV LS_ROOT=/opt/language-server
ENV NODE_ROOT=/opt/node
ENV PATH=${NODE_ROOT}/bin:$PATH

ENV FLINK_HOME=/opt/flink MVN_HOME=/opt/mvn
ENV PATH=${FLINK_HOME}/bin:${MVN_HOME}/bin:$PATH
ENV BUILD_DEPS gpg build-essential
RUN set -eux \
  ; curl --retry 3 -sSLo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/latest/download/gosu-$(dpkg --print-architecture)" \
  ; chmod +x /usr/local/bin/gosu \
  ; gosu nobody true \
  \
  ; groupadd --system --gid=9999 flink \
  ; useradd --system --home-dir $FLINK_HOME --uid=9999 --gid=flink flink \
  \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      openjdk-17-jdk \
      jq ripgrep \
      libsnappy1v5 gettext-base libjemalloc-dev \
      ${BUILD_DEPS} \
  \
  ; mkdir ${MVN_HOME} \
  ; mvn_version=$(curl --retry 3 -sSL https://api.github.com/repos/apache/maven/releases/latest | jq -r '.name') \
  ; curl --retry 3 https://dlcdn.apache.org/maven/maven-3/${mvn_version}/binaries/apache-maven-${mvn_version}-bin.tar.gz \
      | tar zxf - -C ${MVN_HOME} --strip-components=1 \
  \
  \
  ; mkdir -p ${NODE_ROOT} \
  ; node_version=$(curl --retry 3 -sSL https://nodejs.org/en/download/ | rg 'Latest LTS Version.*<strong>(.+)</strong>' -or '$1') \
  ; curl --retry 3 -sSL https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; mkdir -p ${LS_ROOT} \
  ; npm install --location=global \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
  ; chown -R root:root ${NODE_ROOT}/lib \
  ; npm cache clean -f \
  \
  ; nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz" \
  ; curl --retry 3 -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; git clone --depth=1 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nvim; git log -1 --date=iso; cd $opwd \
  ; nvim --headless "+Lazy! sync" +qa \
  \
  ; rm -rf $XDG_CONFIG_HOME/nvim/lazy/packages/*/.git \
  \
  ; nu_ver=$(curl --retry 3 -sSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/latest/download/nu-${nu_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${nu_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/nu' '*/nu_plugin_query' \
  \
  ; zoxide_ver=$(curl --retry 3 -sSL https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; zoxide_url="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-${zoxide_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${zoxide_url} | tar zxf - -C /usr/local/bin zoxide \
  \
  ; for x in nu nu_plugin_query zoxide \
  ; do strip -s /usr/local/bin/$x; done \
  \
  ; echo '/usr/local/bin/nu' >> /etc/shells \
  ; git clone --depth=1 https://github.com/fj0r/nushell.git $XDG_CONFIG_HOME/nushell \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nushell; git log -1 --date=iso; cd $opwd \
  ; nu -c 'register /usr/local/bin/nu_plugin_query' \
  \
  \
  ; FLINK_VERSION=$(curl --retry 3 -sSL https://flink.apache.org/downloads/ | nu -c "cat | query web -q '.markdown > h3:nth-of-type(1)' | parse -r 'Apache Flink (?<ver>[.0-9]+)' | get ver.0") \
  \
  ; mkdir -p ${FLINK_HOME} \
  ; curl --retry 3 -sSL https://dlcdn.apache.org/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_2.12.tgz \
        | tar -zxf - --strip-components=1 -C ${FLINK_HOME} \
  ; chown -R flink:flink ${FLINK_HOME} \
  ; sed -e 's/\(taskmanager.numberOfTaskSlots\): 1/\1: 8/' \
        -e 's/\(rest.address\): localhost/\1: 0.0.0.0/g' \
        -e 's/\(rest.bind-address\): localhost/\1: 0.0.0.0/g' \
        -e 's/\(jobmanager.bind-host\): localhost/\1: 0.0.0.0/g' \
        -e 's/\(taskmanager.bind-host\): localhost/\1: 0.0.0.0/g' \
        -e '/taskmanager.host: localhost/d' \
        -i ${FLINK_HOME}/conf/flink-conf.yaml \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
        'polars[all]' Numpy Pandas numba Scikit-learn \
        apache-flink \
        apache-flink-libraries \
        #apache-flink-statefun \
  \
  # sql-connector-pulsar
  ; cd ${FLINK_HOME}/lib \
  ; repo=https://repo.maven.apache.org/maven2/org/apache/flink \
  ; for c in \
        flink-sql-avro/${FLINK_VERSION}/flink-sql-avro-${FLINK_VERSION}.jar \
        flink-sql-parquet/${FLINK_VERSION}/flink-sql-parquet-${FLINK_VERSION}.jar \
        flink-sql-connector-kafka/${FLINK_VERSION}/flink-sql-connector-kafka-${FLINK_VERSION}.jar \
        flink-sql-connector-pulsar/4.0.0-${FLINK_VERSION::-2}/flink-sql-connector-pulsar-4.0.0-${FLINK_VERSION::-2}.jar \
  ; do \
        curl --retry 3 -sSLO ${repo}/${c} ; \
    done \
  ; chown -R flink:flink ${FLINK_HOME}/lib/ \
  \
  ; apt-get remove -y ${BUILD_DEPS} \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;

WORKDIR $FLINK_HOME
# Configure container
COPY entrypoint /entrypoint
EXPOSE 6123 8081
CMD ["help"]
