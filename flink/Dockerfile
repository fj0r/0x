# https://github.com/apache/flink-docker
FROM fj0rd/io:latest
ARG PIP_FLAGS="--break-system-packages"

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
  ; curl https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc \
  ; echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        temurin-11-jdk \
        libsnappy1v5 gettext-base libjemalloc-dev \
        ${BUILD_DEPS} \
  \
  ; mkdir ${MVN_HOME} \
  ; mvn_version=$(curl --retry 3 -sSL https://api.github.com/repos/apache/maven/releases/latest | jq -r '.name') \
  ; curl --retry 3 https://dlcdn.apache.org/maven/maven-3/${mvn_version}/binaries/apache-maven-${mvn_version}-bin.tar.gz \
      | tar zxf - -C ${MVN_HOME} --strip-components=1 \
  \
  ; FLINK_VERSION=$(curl --retry 3 -sSL https://flink.apache.org/downloads/ | pup '.markdown > h3:nth-of-type(1)' | rg 'Apache Flink ([.0-9]+)' -or '$1') \
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
        apache-flink-statefun \
  \
  # sql-connector-pulsar
  ; repo=https://repo.maven.apache.org/maven2/org/apache/flink \
  ; for c in \
        connector-files \
        sql-avro \
        sql-parquet \
        sql-connector-kafka \
  ; do \
        filename=flink-${c}-${FLINK_VERSION}.jar ; \
        curl --retry 3 -sSLo ${FLINK_HOME}/lib/$filename ${repo}/flink-${c}/${FLINK_VERSION}/$filename ; \
        chown flink:flink ${FLINK_HOME}/lib/$filename ; \
    done \
  ; filename=flink-sql-connector-pulsar-4.0.0-1.17.jar \
  ; curl --retry 3 -sSLo ${FLINK_HOME}/lib/$filename ${repo}/flink-sql-connector-pulsar/4.0.0-1.17/$filename \
  ; chown flink:flink ${FLINK_HOME}/lib/$filename \
  \
  ; apt-get remove -y ${BUILD_DEPS} \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;

WORKDIR $FLINK_HOME
# Configure container
COPY entrypoint /entrypoint
EXPOSE 6123 8081
CMD ["help"]
