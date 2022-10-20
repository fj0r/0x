FROM fj0rd/io

ENV PATH=/opt/mvn/bin:/opt/language-server/jdtls/bin:$PATH

RUN set -eux \
  ; DEBIAN_FRONTEND=noninteractive \
  ; curl -sSL https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add - \
  ; add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; apt-get install -y --no-install-recommends adoptopenjdk-8-hotspot build-essential \
  ; mkdir /opt/mvn \
  ; mvn_version=$(curl -sSL https://api.github.com/repos/apache/maven/releases -H 'Accept: application/vnd.github.v3+json' \
      | jq -r '[.[]|select(.prerelease == false)][0].name') \
  ; curl https://dlcdn.apache.org/maven/maven-3/${mvn_version}/binaries/apache-maven-${mvn_version}-bin.tar.gz \
      | tar zxf - -C /opt/mvn --strip-components=1 \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/lib/jvm/java-8-openjdk-amd64

RUN set -eux \
  ; mkdir -p /opt/language-server/jdtls \
  ; jdtls_latest=$(curl -sSL https://download.eclipse.org/jdtls/snapshots/latest.txt) \
  ; curl -sSL https://download.eclipse.org/jdtls/snapshots/${jdtls_latest} \
    | tar --no-same-owner -zxf - -C /opt/language-server/jdtls \
  \
  ; echo 'done'

