FROM flink:java17

#ARG PIP_FLAGS="--break-system-packages"
ARG PIP_FLAGS=""
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        python3 python3-pip \
        ripgrep \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
        httpx aiofile aiostream fastapi uvicorn \
        debugpy pytest pydantic PyParsing \
        ipython typer pydantic-settings pyyaml \
        boltons decorator \
        \
        Numpy Pandas numba Scikit-learn \
        apache-flink \
        apache-flink-libraries \
        #apache-flink-statefun \
  ; apt-get autoremove -y && apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

RUN set -eux \
  ; FLINK_VERSION=$(flink --version | rg 'Version: (.+?),' -or '$1') \
  ; cd ${FLINK_HOME}/lib \
  ; repo=https://repo.maven.apache.org/maven2/org/apache/flink \
  ; for c in \
        flink-sql-avro/${FLINK_VERSION}/flink-sql-avro-${FLINK_VERSION}.jar \
        flink-sql-parquet/${FLINK_VERSION}/flink-sql-parquet-${FLINK_VERSION}.jar \
        flink-sql-connector-kafka/${FLINK_VERSION}/flink-sql-connector-kafka-${FLINK_VERSION}.jar \
        flink-sql-connector-pulsar/3.0.0-1.16/flink-sql-connector-pulsar-3.0.0-1.16.jar \
  ; do \
        curl --retry 3 -sSLO ${repo}/${c} ; \
    done \
  ; chown -R flink:flink ${FLINK_HOME}/lib/ \
  ;
