# https://github.com/apache/flink-docker
FROM fj0rd/0x:py39

ARG FLINK_VERSION=1.16.1
ENV FLINK_HOME=/opt/flink MVN_HOME=/opt/mvn
ENV PATH=${FLINK_HOME}/bin:${MVN_HOME}/bin:$PATH
ENV BUILD_DEPS gpg build-essential
RUN set -eux \
  ; curl -sSLo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/latest/download/gosu-$(dpkg --print-architecture)" \
  ; chmod +x /usr/local/bin/gosu \
  ; gosu nobody true \
  \
  ; groupadd --system --gid=9999 flink \
  ; useradd --system --home-dir $FLINK_HOME --uid=9999 --gid=flink flink \
  \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        openjdk-11-jdk \
        libsnappy1v5 gettext-base libjemalloc-dev \
        ${BUILD_DEPS} \
  \
  ; mkdir ${MVN_HOME} \
  ; mvn_version=$(curl -sSL https://api.github.com/repos/apache/maven/releases/latest | jq -r '.name') \
  ; curl https://dlcdn.apache.org/maven/maven-3/${mvn_version}/binaries/apache-maven-${mvn_version}-bin.tar.gz \
      | tar zxf - -C ${MVN_HOME} --strip-components=1 \
  \
  ; mkdir -p ${FLINK_HOME} \
  ; curl -sSL https://dlcdn.apache.org/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_2.12.tgz \
        | tar -zxf - --strip-components=1 -C ${FLINK_HOME} \
  ; chown -R flink:flink ${FLINK_HOME} \
  ; sed -e 's/\(taskmanager.numberOfTaskSlots\): 1/\1: 8/' \
        -e 's/\(rest.address\): localhost/\1: 0.0.0.0/g' \
        -e 's/\(rest.bind-address\): localhost/\1: 0.0.0.0/g' \
        -e 's/\(jobmanager.bind-host\): localhost/\1: 0.0.0.0/g' \
        -e 's/\(taskmanager.bind-host\): localhost/\1: 0.0.0.0/g' \
        -e '/taskmanager.host: localhost/d' \
        -i ${FLINK_HOME}/conf/flink-conf.yaml \
  ; pip3 install --no-cache-dir apache-flink apache-flink-libraries \
        # numpy pandas \
        debugpy pydantic pytest \
        httpx hydra-core typer pyyaml deepmerge \
        PyParsing structlog python-json-logger \
        decorator more-itertools cachetools \
  ; apt-get remove -y ${BUILD_DEPS} \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;

RUN set -eux \
  ; for c in avro parquet connector-kafka connector-pulsar; do \
        curl -sSLo ${FLINK_HOME}/lib/flink-sql-${c}-${FLINK_VERSION}.jar \
        https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-${c}/${FLINK_VERSION}/flink-sql-${c}-${FLINK_VERSION}.jar ; \
        chown flink:flink ${FLINK_HOME}/lib/flink-sql-${c}-${FLINK_VERSION}.jar; \
    done \
  ;

WORKDIR $FLINK_HOME
# Configure container
COPY entrypoint /entrypoint
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 6123 8081
CMD ["help"]
