FROM fj0rd/io

ENV PATH=/opt/mvn/bin:/opt/language-server/jdtls/bin:$PATH
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; mkdir -p /usr/share/man/man1 \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      openjdk-11-jdk \
  ; mkdir /opt/mvn \
  ; mvn_version=$(curl -sSL https://api.github.com/repos/apache/maven/releases -H 'Accept: application/vnd.github.v3+json' \
      | jq -r '[.[]|select(.prerelease == false)][0].name') \
  ; curl https://dlcdn.apache.org/maven/maven-3/${mvn_version}/binaries/apache-maven-${mvn_version}-bin.tar.gz \
      | tar zxf - -C /opt/mvn --strip-components=1 \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

RUN set -eux \
  ; mkdir -p /opt/language-server/jdtls \
  ; jdtls_latest=$(curl -sSL https://download.eclipse.org/jdtls/snapshots/latest.txt) \
  ; curl -sSL https://download.eclipse.org/jdtls/snapshots/${jdtls_latest} \
    | tar --no-same-owner -zxf - -C /opt/language-server/jdtls \
  \
  ; echo 'done'

