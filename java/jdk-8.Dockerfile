FROM fj0rd/io:root

ENV PATH=/opt/mvn/bin:${LS_ROOT}/jdtls/bin:$PATH

RUN set -eux \
  ; DEBIAN_FRONTEND=noninteractive \
  ; curl --retry 3 -fsSL https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
  ; add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; apt-get install -y --no-install-recommends adoptopenjdk-8-hotspot build-essential \
  ; mkdir /opt/mvn \
  ; mvn_version=$(curl --retry 3 -fsSL https://api.github.com/repos/apache/maven/releases/latest | jq -r '.name') \
  ; curl --retry 3 https://dlcdn.apache.org/maven/maven-3/${mvn_version}/binaries/apache-maven-${mvn_version}-bin.tar.gz \
      | tar zxf - -C /opt/mvn --strip-components=1 \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

ENV JAVA_HOME=/lib/jvm/java-8-openjdk-amd64

RUN set -eux \
  ; mkdir -p ${LS_ROOT}/jdtls \
  ; jdtls_latest=$(curl --retry 3 -fsSL https://download.eclipse.org/jdtls/snapshots/latest.txt) \
  ; curl --retry 3 -fsSL https://download.eclipse.org/jdtls/snapshots/${jdtls_latest} \
    | tar --no-same-owner -zxf - -C ${LS_ROOT}/jdtls \
  \
  ; echo 'done'

