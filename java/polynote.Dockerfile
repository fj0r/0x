FROM fj0rd/0x:java11
#https://github.com/mbari-org/docker-polynote/blob/master/Dockerfile.jdk11

WORKDIR /opt

ARG DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED TRUE

RUN set eux \
  ; cp /etc/apt/sources.list /etc/apt/sources.list.$(date +%y%m%d%H%M%S) \
  ; sed -i 's/\(archive\|security\).ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list \
  ; apt-get update \
  ; apt-get install -y \
      python3-dev

ARG github_header="-H 'Accept: application/vnd.github.v3+json'"
ARG github_api=https://api.github.com/repos
ARG spark_repo=apache/spark
ARG polynote_repo=polynote/polynote

WORKDIR /opt
RUN set -eux \
  ; spark_version=$(curl --retry 3 -fsSL $github_api/${spark_repo}/releases $github_header | jq -r '.[0].tag_name'|cut -c 2-) \
  ; spark_version=3.1.2 \
  ; pip3 install \
      jep \
      jedi \
      pyspark==${spark_version} \
      virtualenv \
      numpy \
      pandas \
  ; curl --retry 3 -fsSL http://apache.claz.org/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop3.2.tgz | tar -xzvpf - \
  ; mv spark* /opt/spark \
  ; polynote_version=$(curl --retry 3 -fsSL $github_api/${polynote_repo}/releases $github_header | jq -r '.[0].tag_name') \
  ; curl --retry 3 -fsSL https://github.com/polynote/polynote/releases/download/${polynote_version}/polynote-dist.tar.gz | tar -xzvpf -

ENV PYSPARK_ALLOW_INSECURE_GATEWAY 1
ENV SPARK_HOME /opt/spark
ENV PATH "$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin"

COPY config.yml ./polynote/config.yml

EXPOSE 8192

CMD ["/opt/polynote/polynote.py"]
