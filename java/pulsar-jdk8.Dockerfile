FROM fj0rd/java:8

WORKDIR /pulsar
ENV PATH=/pulsar/bin:$PATH
ARG github_header="Accept:application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos
ARG pulsar_repo=apache/pulsar
ARG pulsarctl_repo=streamnative/pulsarctl
RUN set -eux \
  ; pulsar_version=$(xh $github_api/${pulsar_repo}/releases $github_header | jq -r '.[0].tag_name'|cut -c 2-) \
  ; pulsar_url="https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=pulsar/pulsar-${pulsar_version}/apache-pulsar-${pulsar_version}-bin.tar.gz" \
  ; xh -F ${pulsar_url} | tar zxf - -C /pulsar --strip-components=1 \
  \
  ; pulsarctl_version=$(xh $github_api/${pulsarctl_repo}/releases $github_header | jq -r '.[0].tag_name') \
  ; pulsarctl_url=https://github.com/${pulsarctl_repo}/releases/download/${pulsarctl_version}/pulsarctl-amd64-linux.tar.gz \
  ; xh -F ${pulsarctl_url} | tar zxf - -C /usr/local/bin --strip-components=1 \
  \
  ; pip3 --default-timeout=100 --no-cache-dir install pulsar-client==${pulsar_version} \
  ; pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
