FROM fj0rd/io:base

ARG OSSUTIL_URL=https://gosspublic.alicdn.com/ossutil/1.7.3/ossutil64?spm=a2c4g.11186623.2.10.b79f7385xBOwEo
ARG watchexec_repo=watchexec/watchexec
ARG github_header="Accept:application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      locales ca-certificates \
  \
  ; watchexec_ver=$(xh $github_api/${watchexec_repo}/releases $github_header | jq -r '.[0].tag_name' | cut -c 6-) \
  ; watchexec_url=https://github.com/${watchexec_repo}/releases/download/cli-v${watchexec_ver}/watchexec-${watchexec_ver}-x86_64-unknown-linux-musl.tar.xz \
  ; xh -F ${watchexec_url} | tar Jxf - --strip-components=1 -C /usr/local/bin watchexec-${watchexec_ver}-x86_64-unknown-linux-musl/watchexec \
  \
  ; xh -F ${OSSUTIL_URL} -o /usr/local/bin/ossutil \
  ; chmod +x /usr/local/bin/ossutil \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV SYNC_CONFIG=/ossutilconfig
ENV SYNC_SRC=/data
ENV SYNC_TG=bucket/
COPY sync /sync
ENTRYPOINT [ "bash", "/sync/watch.sh" ]
