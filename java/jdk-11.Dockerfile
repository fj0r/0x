FROM fj0rd/io:stable

ENV PATH=/opt/mvn/bin:$PATH
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; mkdir -p /usr/share/man/man1 \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      openjdk-11-jdk \
  ; mkdir /opt/mvn \
  ; mvn_version=$(curl --retry 3 -sSL https://api.github.com/repos/apache/maven/releases/latest | jq -r '.name') \
  ; curl https://dlcdn.apache.org/maven/maven-3/${mvn_version}/binaries/apache-maven-${mvn_version}-bin.tar.gz \
      | tar zxf - -C /opt/mvn --strip-components=1 \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

#RUN set -eux \
#  ; cd /world \
#  ; mvn archetype:generate -DgroupId=com.java.hello -DartifactId=hello-java \
#        -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
