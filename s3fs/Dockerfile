FROM fj0rd/scratch:dropbear as dropbear

FROM debian:bullseye-slim
COPY --from=dropbear / /
ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; cp /etc/apt/sources.list /etc/apt/sources.list.ustc \
  ; sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1mirrors.ustc.edu.cn\3main contrib non-free/g' /etc/apt/sources.list.ustc \
  \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      s3fs tzdata jq rsync \
      procps htop curl ca-certificates \
      lsof inetutils-ping iproute2 iptables net-tools \
      tree fuse xz-utils zstd zip unzip \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  #; sed -i /etc/locale.gen \
  #      -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
  #      -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  #; locale-gen \
  \
  ; mkdir -p /etc/dropbear \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


WORKDIR /data
ENV S3URL=
ENV S3BUCKET=
ENV S3PATH=/
ENV S3ENDPOINT=
ENV S3ACCESS_KEY=
ENV S3SECRET_KEY=

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
