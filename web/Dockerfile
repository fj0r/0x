FROM debian:bullseye-slim
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; cp /etc/apt/sources.list /etc/apt/sources.list.origin \
  #; sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1mirrors.ustc.edu.cn\3main contrib non-free/g' /etc/apt/sources.list \
  \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      nginx ca-certificates \
      curl tzdata sudo jq rsync tcpdump socat htop \
      lsof inetutils-ping iproute2 nftables net-tools \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
