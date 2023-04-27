FROM fj0rd/io

ENV PATH=/opt/mvn/bin:${LS_ROOT}/jdtls/bin:$PATH
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; mkdir -p /usr/share/man/man1 \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      openjdk-17-jdk \
  ; mkdir /opt/mvn \
  ; mvn_version=$(curl -sSL https://api.github.com/repos/apache/maven/releases/latest | jq -r '.name') \
  ; curl https://dlcdn.apache.org/maven/maven-3/${mvn_version}/binaries/apache-maven-${mvn_version}-bin.tar.gz \
      | tar zxf - -C /opt/mvn --strip-components=1 \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; cd /world \
  ; mvn archetype:generate -DgroupId=com.java.hello -DartifactId=hello-java \
        -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false

# requires at least Java 17
RUN set -eux \
  ; mkdir -p ${LS_ROOT}/jdtls \
  ; jdtls_latest=$(curl -sSL https://download.eclipse.org/jdtls/snapshots/latest.txt) \
  ; curl -sSL https://download.eclipse.org/jdtls/snapshots/${jdtls_latest} \
    | tar --no-same-owner -zxf - -C ${LS_ROOT}/jdtls \
  \
  ; echo 'done'

