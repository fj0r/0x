FROM fj0rd/0x:java17 AS build

WORKDIR /pulsar
RUN set -eux \
  ; pulsar_version=$(curl --retry 3 -sSL https://api.github.com/repos/apache/pulsar/releases -H "Accept: application/vnd.github.v3+json" | jq -r '.[0].tag_name'|cut -c 2-) \
  ; curl --retry 3 -sSL https://github.com/apache/pulsar/archive/refs/tags/v${pulsar_version}.tar.gz | tar zxf - --strip-components=1 \
  ; mvn install -Pcore-modules,-main -DskipTests \
  ; mkdir /opt/pulsar \
  ; tar zxf ~/.m2/repository/org/apache/pulsar/pulsar-server-distribution/${pulsar_version}/pulsar-server-distribution-${pulsar_version}-bin.tar.gz -C /opt/pulsar --strip-components=1
  \
  # \
  # ; pip3 --default-timeout=100 --no-cache-dir install pulsar-client==${pulsar_version} \
  # ; pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple


FROM fj0rd/0x:java17
ENV PATH=/pulsar/bin:$PATH
WORKDIR /pulsar
COPY --from=build /opt/pulsar /pulsar

